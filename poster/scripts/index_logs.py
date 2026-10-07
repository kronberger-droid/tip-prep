"""Index a directory of tip-prep logs into a small cache, then rank the runs.

The logs on the data drive run to gigabytes each, since every pulse carries the
full `signal_frames` TCP capture in `ExperimentData`. Decoding them with
`json.load` or even `raw_decode` (see `scan_logs.py`) means materialising those
arrays just to read one float out of the record next to them.

The files are pretty-printed, so every field the poster cares about sits alone
on its own line at a known indentation depth. `rg` pulls those ~700 lines out
of a 120 MB file in 0.4 s, disk-bound. So:

    stage 1  scan the drive once, write a compact JSON index   (minutes)
    stage 2  rank and re-rank the index                        (instant)

Usage:
    python3 scripts/index_logs.py scan "/run/media/.../Experiments"  # -> cache
    python3 scripts/index_logs.py report                             # re-rank
    python3 scripts/index_logs.py report --min-pulses 10 --sharp-only
"""
import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime

DEFAULT_CACHE = os.path.join(os.path.dirname(__file__), "runs_index.json")

# Anchored on exact indentation, so these are structural queries and not just
# text matches: indent 4 is a top-level record field, indent 6 inside `result`
# is the result variant name, indent 8 is a field of that variant.
PATTERNS = [
    r'^    "action": ',
    r'^    "result": ',
    r'^    "start_time": ',
    r'^    "duration_ms": ',
    r'^      "[A-Za-z_]+": \{$',
    r'^      "Error": ',
    r'^        "stable_value": ',
    r'^        "shape": ',
]

BOUNDS_RE = re.compile(r"bounds \(([-0-9.e]+), ([-0-9.e]+)\)")
PULSE_V_RE = re.compile(r"Pulse retract (-?[0-9.]+)V")
SWEEP_RE = re.compile(
    r"bias sweep .*? from (-?[0-9.]+)V to (-?[0-9.]+)V \((\d+) steps, (\d+)ms"
)


def _unquote(line, prefix):
    """Take the JSON value off a `    "key": <value>,` line."""
    val = line[len(prefix):].rstrip().rstrip(",")
    try:
        return json.loads(val)
    except ValueError:
        return val


def records(path):
    """Stream (action, result_kind, detail, fields) per record, via ripgrep.

    `"action"` delimits records: it is the first key of every object, so a new
    action line means the previous record is complete.
    """
    proc = subprocess.Popen(
        ["rg", "-N"] + [x for p in PATTERNS for x in ("-e", p)] + ["--", path],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        errors="replace",
    )
    cur = None
    for line in proc.stdout:
        if line.startswith('    "action": '):
            if cur:
                yield cur
            cur = {"action": _unquote(line, '    "action": '), "kind": None}
        elif cur is None:
            continue
        elif line.startswith('    "result": '):
            rest = line[len('    "result": '):].strip()
            if rest.startswith("{"):
                cur["kind"] = "?"          # variant name lands on the next line
            else:
                cur["kind"] = _unquote(line, '    "result": ')
        elif line.startswith('    "start_time": '):
            cur["start"] = _unquote(line, '    "start_time": ')
        elif line.startswith('    "duration_ms": '):
            cur["dur"] = _unquote(line, '    "duration_ms": ')
        elif line.startswith('      "Error": '):
            cur["kind"] = "Error"
            cur["error"] = _unquote(line, '      "Error": ')
        elif line.startswith('      "') and line.rstrip().endswith("{"):
            if cur.get("kind") in (None, "?"):
                cur["kind"] = line.strip().split('"')[1]
        elif line.startswith('        "stable_value": '):
            cur["df"] = _unquote(line, '        "stable_value": ')
        elif line.startswith('        "shape": '):
            cur["shape"] = _unquote(line, '        "shape": ')
    if cur:
        yield cur
    proc.stdout.close()
    proc.wait()


def is_truncated(path):
    """A run killed mid-write never closed its top-level array."""
    with open(path, "rb") as f:
        f.seek(max(0, os.path.getsize(path) - 64))
        return not f.read().rstrip().endswith(b"]")


def parse_time(s):
    # Rust writes 9 fractional digits; datetime wants at most 6.
    s = re.sub(r"(\.\d{6})\d*", r"\1", s.replace("Z", "+00:00"))
    try:
        return datetime.fromisoformat(s)
    except ValueError:
        return None


def summarise(path):
    df, shapes, pulse_v, errors = [], [], [], []
    bounds = sweep = None
    n = 0
    t_first = t_last = dur_last = None
    stability = []

    for r in records(path):
        n += 1
        act = r["action"]
        if "df" in r:
            df.append(r["df"])
        if "shape" in r:
            shapes.append(r["shape"])
        if r.get("kind") == "Error":
            errors.append((act[:60], r.get("error", "")[:120]))
        # "Data Collection:" duplicates the pulse record it wraps.
        if act.startswith("Pulse retract"):
            m = PULSE_V_RE.search(act)
            if m:
                pulse_v.append(float(m.group(1)))
        if bounds is None and "Check tip state" in act:
            m = BOUNDS_RE.search(act)
            if m:
                bounds = (float(m.group(1)), float(m.group(2)))
        if "Check tip stability" in act:
            m = SWEEP_RE.search(act)
            if sweep is None and m:
                sweep = {
                    "from": float(m.group(1)), "to": float(m.group(2)),
                    "steps": int(m.group(3)), "period_ms": int(m.group(4)),
                }
            stability.append(r.get("kind") or "Success")
        if "start" in r:
            t = parse_time(r["start"])
            if t:
                t_first = t_first or t
                t_last = t
                dur_last = r.get("dur") or 0

    secs = None
    if t_first and t_last:
        secs = (t_last - t_first).total_seconds() + (dur_last or 0) / 1000.0

    return {
        "file": os.path.basename(path),
        "size_mb": round(os.path.getsize(path) / 1e6, 1),
        "truncated": is_truncated(path),
        "entries": n,
        "seconds": round(secs, 1) if secs else None,
        "pulses": len(pulse_v),
        "pulse_v": sorted(set(pulse_v)),
        "reads": len(df),
        "df": [round(v, 3) for v in df],
        "shapes": shapes,
        "sharp_bounds": bounds,
        "sweep": sweep,
        "stability_results": stability,
        "errors": errors[:5],
    }


# ---------------------------------------------------------------- reporting

def verdict(s):
    """Classify a run the way the Proof of Concept panel would read it."""
    df, shapes = s["df"], s["shapes"]
    if not df:
        return "no reads"
    if "Sharp" not in shapes:
        return "never sharp"
    if len(df) < 2:
        return "sharp, single read"
    # Δf climbing toward the sharp band (bounds are negative, target ~0).
    gain = abs(df[0]) - abs(df[-1])
    if s["pulses"] == 0:
        return "already sharp"
    # Deliberately not "converged": the loop is a random search that either
    # lands in the band or does not. Calling it convergence implies a trend the
    # traces do not show. See the house-style note in CLAUDE.md.
    return f"reached band {gain:+.1f} Hz" if gain > 0 else f"worse {gain:+.1f} Hz"


def score(s):
    """Rank for poster use: sharp, long, big honest improvement, intact."""
    if not s["df"] or "Sharp" not in s["shapes"]:
        return -1
    gain = abs(s["df"][0]) - abs(s["df"][-1])
    v = s["pulses"] * 2 + max(gain, 0)
    if s["truncated"]:
        v -= 5
    if any(k != "Error" for k in s["stability_results"]):
        v += 25          # a passed stability check is what the poster lacks
    return v


def report(index, min_pulses=0, sharp_only=False):
    rows = sorted(index, key=score, reverse=True)
    hdr = f"{'file':<32}{'MB':>7}{'ent':>6}{'s':>7}{'puls':>5}{'rd':>4}  {'Δf first→last':<16}{'stab':<6}verdict"
    print(hdr)
    print("-" * len(hdr))
    for s in rows:
        if s["pulses"] < min_pulses:
            continue
        if sharp_only and "Sharp" not in s["shapes"]:
            continue
        df = s["df"]
        span = f"{df[0]:>7.2f} →{df[-1]:>7.2f}" if df else " " * 16
        stab = ""
        if s["stability_results"]:
            ok = sum(1 for k in s["stability_results"] if k != "Error")
            stab = f"{ok}/{len(s['stability_results'])}"
        print(
            f"{s['file'].replace('tip_prep_', ''):<32}"
            f"{s['size_mb']:>7}{s['entries']:>6}"
            f"{(s['seconds'] or 0):>7.0f}{s['pulses']:>5}{s['reads']:>4}  "
            f"{span:<16}{stab:<6}"
            f"{'TRUNC ' if s['truncated'] else ''}{verdict(s)}"
        )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["scan", "report"])
    ap.add_argument("dir", nargs="?")
    ap.add_argument("--cache", default=DEFAULT_CACHE)
    ap.add_argument("--min-pulses", type=int, default=0)
    ap.add_argument("--sharp-only", action="store_true")
    a = ap.parse_args()

    if a.mode == "scan":
        if not a.dir:
            sys.exit("scan needs a directory")
        paths = sorted(
            os.path.join(a.dir, f) for f in os.listdir(a.dir)
            if f.startswith("tip_prep_") and f.endswith(".json")
        )
        index = []
        for i, p in enumerate(paths, 1):
            print(f"[{i}/{len(paths)}] {os.path.basename(p)}", file=sys.stderr,
                  flush=True)
            try:
                index.append(summarise(p))
            except Exception as e:                       # keep going
                print(f"    failed: {e}", file=sys.stderr)
        with open(a.cache, "w") as f:
            json.dump(index, f, indent=1)
        print(f"wrote {a.cache} ({len(index)} runs)", file=sys.stderr)
    else:
        index = json.load(open(a.cache))

    report(index, a.min_pulses, a.sharp_only)


main()
