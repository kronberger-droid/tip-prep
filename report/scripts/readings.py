"""Histogram of the accepted frequency-shift readings, for fig_readings.

Reads the run logs the report counts (tip_prep_*.jsonl from 2026-09-15 to
2026-10-06 whose run finished `completed` or `stopped_by_user`, as in
src/06_validation) and writes data/readings.json: counts per 2 Hz bin from
-80 to +80 Hz, split by whether the reading passed the noise and drift gates
or failed them on every retry, plus the readings outside that span.

A reading is a `data_collected` record labelled `stable_read`; `stable`
false means it failed the gates on every retry and was used anyway.

Usage:
    python3 scripts/readings.py "/run/media/kronberger/DATA/Tip Prep/Experiments"
"""
import json
import math
import os
import sys

FIRST, LAST = "20260915", "20261006"
COUNTED = ("completed", "stopped_by_user")
LO, HI, WIDTH = -80, 80, 2
RAIL = 76.29


def readings(root):
    for name in sorted(os.listdir(root)):
        if not (name.startswith("tip_prep_") and name.endswith(".jsonl")):
            continue
        if not FIRST <= name[9:17] <= LAST:
            continue
        reads, outcome = [], None
        with open(os.path.join(root, name)) as f:
            for line in f:
                if '"stable_read"' in line or '"run_finished"' in line:
                    r = json.loads(line)
                    if r["type"] == "run_finished":
                        outcome = r["outcome"]
                    elif r["type"] == "data_collected" and r["label"] == "stable_read":
                        reads.append(r["value"])
        if outcome in COUNTED:
            yield from reads


def main(root):
    n = (HI - LO) // WIDTH
    passed, failed = [0] * n, [0] * n
    outside = {"passed": 0, "failed": 0}
    total = at_rail = 0
    for r in readings(root):
        total += 1
        v = r["value"]
        at_rail += abs(abs(v) - RAIL) < 0.015
        key = "passed" if r["stable"] else "failed"
        i = math.floor((v - LO) / WIDTH)
        if 0 <= i < n:
            (passed if r["stable"] else failed)[i] += 1
        else:
            outside[key] += 1
    result = {
        "source": f"stable_read records of the counted tip_prep logs, {FIRST} to {LAST}",
        "readings": total,
        "at_rail": at_rail,
        "bin_width_hz": WIDTH,
        "bin_starts_hz": [LO + i * WIDTH for i in range(n)],
        "passed": passed,
        "failed": failed,
        "outside": outside,
    }
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "..", "data", "readings.json"), "w") as f:
        json.dump(result, f, indent=2)
        f.write("\n")
    print({k: result[k] for k in ("readings", "at_rail", "outside")},
          "passed", sum(passed), "failed", sum(failed),
          "max bin", max(p + q for p, q in zip(passed, failed)))


if __name__ == "__main__":
    main(sys.argv[1])
