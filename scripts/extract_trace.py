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
PULSE_RE = re.compile(r"^Pulse retract (-?[0-9.]+)V")


def extract(path):
    cmd = ["rg", "-N"] + [x for p in PATTERNS for x in ("-e", p)] + ["--", path]
    out = subprocess.run(cmd, capture_output=True, text=True).stdout

    reads, shapes, pulses = [], [], []
    bounds = None
    pending = None          # a stable_value waiting for its state check
    t_first = t_last = None

    for line in out.splitlines():
        s = line.strip()
        if s.startswith('"action"'):
            # Strip the key, then the JSON quotes around the value itself.
            act = s[len('"action": '):].strip().rstrip(',').strip('"')
            m = PULSE_RE.match(act)
            if m:
                pulses.append(float(m.group(1)))
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
            if pending is not None:
                reads.append(round(pending, 3))
                shapes.append(s.split(':')[1].strip().strip('",'))
                pending = None

    return {
        "file": os.path.basename(path),
        "df": reads,
        "shape": shapes,
        "pulses": len(pulses),
        "pulse_voltages": sorted(set(pulses)),
        "sharp_bounds": bounds,
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
        print(f"{r['file']}: {len(r['df'])} reads, {r['pulses']} pulses, "
              f"bounds {r['sharp_bounds']}", file=sys.stderr)
        runs.append(r)
    with open(out_path, "w") as f:
        json.dump({"runs": runs}, f, indent=1)
    print(f"wrote {out_path}", file=sys.stderr)


main()
