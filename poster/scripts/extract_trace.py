"""Extract the Δf trace of one or more runs into a small JSON the poster reads.

`figures/convergence.typ` used to carry its numbers as hand-typed arrays. That
is fine for a 10-point run and unworkable for a 295-point one, and it also puts
the provenance in a comment where nothing checks it. This writes the traces plus
their provenance to one file that Typst loads with `json()`, so the poster still
builds with the data drive unplugged.

Usage:
    python3 scripts/extract_trace.py figures/traces.json LOG [LOG ...]

Each read in the output is one `Get stable signal` result paired with the
`Check tip state` verdict that followed it, so `df[i]` and `shape[i]` describe
the same moment. Reads with no following state check are dropped.

Every read also gets a `phase`, which is what lets the figure colour the
stability check separately from the pulse loop:

    loop        a read that follows a bias pulse, i.e. the conditioning loop
    confirm     a read with no pulse since the previous one. `check_stability`
                opens with `confirm_sharp`, CONFIRMATION_READS reads that
                reposition but never pulse, so "no pulse since the last read"
                identifies them exactly
    post_sweep  the first read after a `Check tip stability` action

`stability` collects one entry per check that reached its sweeps, with the
baseline (the last `confirm` read), the `post_sweep` read, and the verdict.
`runner.rs::check_stability` computes that verdict as
`|final - baseline| <= stable_tip_allowed_change`, so it is recomputed here
rather than read out of the log: the per-sweep `TipState` in these files comes
from an action that no longer exists in `rusty-tip`, and its `is_stable` flag
does not agree with the loop's own behaviour. The tolerance is parsed off the
action string, which prints it as a percentage but stores Hz, so "200.0% change
allowed" is 2.0 Hz.
"""
import json
import os
import re
import subprocess
import sys

PATTERNS = [
    r'^    "action": ',
    r'^    "start_time": ',
    r'^        "stable_value": ',
    r'^        "shape": ',
]
BOUNDS_RE = re.compile(r"bounds \(([-0-9.e]+), ([-0-9.e]+)\)")
# Two log generations: `Pulse retract -4.0V` (Dec 2025) and `Bias pulse
# -8.000V` (2026). Matching only the first silently reported 0 pulses for every
# 2026 run, which is how a 36-pulse run looked like a 0-pulse one in the index.
PULSE_RE = re.compile(r"^(?:Pulse retract|Bias pulse) (-?[0-9.]+)V")
SWEEP_RE = re.compile(
    r"Check tip stability: bias sweep .*? from (-?[0-9.]+)V to (-?[0-9.]+)V"
    r" \((\d+) steps, (\d+)ms period, ([0-9.]+)% change allowed"
)


def extract(path):
    cmd = ["rg", "-N"] + [x for p in PATTERNS for x in ("-e", p)] + ["--", path]
    out = subprocess.run(cmd, capture_output=True, text=True).stdout

    reads, shapes, phases, pulses = [], [], [], []
    bounds = None
    pending = None          # a stable_value waiting for its state check
    t_first = t_last = None

    # Reset at every committed read: they describe what happened in the gap
    # between the previous read and this one.
    pulsed_since_read = True    # the first read of a run counts as loop
    swept_since_read = False
    sweeps = []                 # sweeps seen since the last read
    stability = []
    tolerance = None

    for line in out.splitlines():
        s = line.strip()
        if s.startswith('"action"'):
            # Strip the key, then the JSON quotes around the value itself.
            act = s[len('"action": '):].strip().rstrip(',').strip('"')
            m = PULSE_RE.match(act)
            if m:
                pulses.append(float(m.group(1)))
                pulsed_since_read = True
            sw = SWEEP_RE.search(act)
            if sw:
                swept_since_read = True
                sweeps.append({
                    "from": float(sw.group(1)),
                    "to": float(sw.group(2)),
                    "steps": int(sw.group(3)),
                    "period_ms": int(sw.group(4)),
                })
                tolerance = float(sw.group(5)) / 100.0
            if bounds is None and "Check tip state" in act:
                b = BOUNDS_RE.search(act)
                if b:
                    bounds = [float(b.group(1)), float(b.group(2))]
        elif s.startswith('"start_time"'):
            t = s.split(': ', 1)[1].strip('",')
            t_first = t_first or t
            t_last = t
        elif s.startswith('"stable_value"'):
            pending = float(s.split(':')[1].strip().rstrip(','))
        elif s.startswith('"shape"'):
            if pending is None:
                continue        # a sweep's own TipState, not a read
            if swept_since_read:
                phase = "post_sweep"
            elif pulsed_since_read:
                phase = "loop"
            else:
                phase = "confirm"

            reads.append(round(pending, 3))
            shapes.append(s.split(':')[1].strip().strip('",'))
            phases.append(phase)

            if phase == "post_sweep":
                # Baseline is the last `confirm` read before the sweeps.
                prev = [i for i, p in enumerate(phases[:-1]) if p == "confirm"]
                baseline = reads[prev[-1]] if prev else None
                final = reads[-1]
                change = abs(final - baseline) if baseline is not None else None
                stability.append({
                    "sweeps": sweeps,
                    "tolerance_hz": tolerance,
                    "baseline": baseline,
                    "final": final,
                    "change": None if change is None else round(change, 3),
                    "passed": None if change is None else change <= tolerance,
                    "baseline_index": prev[-1] if prev else None,
                    "final_index": len(reads) - 1,
                })

            pending = None
            pulsed_since_read = False
            swept_since_read = False
            sweeps = []

    return {
        "file": os.path.basename(path),
        "df": reads,
        "shape": shapes,
        "phase": phases,
        "pulses": len(pulses),
        "pulse_voltages": sorted(set(pulses)),
        "sharp_bounds": bounds,
        "stability": stability,
        "start": t_first,
        "end": t_last,
    }


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    out_path, logs = sys.argv[1], sys.argv[2:]
    runs = []
    for p in logs:
        r = extract(p)
        checks = ", ".join(
            f"{c['change']} Hz vs {c['tolerance_hz']} Hz -> "
            f"{'pass' if c['passed'] else 'FAIL'}" for c in r["stability"]
        ) or "none"
        print(f"{r['file']}: {len(r['df'])} reads, {r['pulses']} pulses, "
              f"bounds {r['sharp_bounds']}, "
              f"{r['phase'].count('confirm')} confirm reads; checks: {checks}",
              file=sys.stderr)
        runs.append(r)
    with open(out_path, "w") as f:
        json.dump({"runs": runs}, f, indent=1)
    print(f"wrote {out_path}", file=sys.stderr)


main()
