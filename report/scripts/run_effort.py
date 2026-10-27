"""Pulses and minutes of each completed run, for fig_effort.

Reads the run logs the report counts (tip_prep_*.jsonl from 2026-09-15 to
2026-10-06 whose run finished `completed` or `stopped_by_user`, as in
src/06_validation) and writes data/run_effort.json with one entry per
completed run. Pulses are the run's `tip_prep/cycle` events; minutes are the
`run_finished` duration, which the logs give in milliseconds.

Usage:
    python3 scripts/run_effort.py "/run/media/kronberger/DATA/Tip Prep/Experiments"
"""
import json
import os
import statistics
import sys

FIRST, LAST = "20260915", "20261006"
COUNTED = ("completed", "stopped_by_user")


def main(root):
    runs = []
    counted = 0
    for name in sorted(os.listdir(root)):
        if not (name.startswith("tip_prep_") and name.endswith(".jsonl")):
            continue
        if not FIRST <= name[9:17] <= LAST:
            continue
        pulses, outcome, ms = 0, None, None
        with open(os.path.join(root, name)) as f:
            for line in f:
                # The header's event schema names the kind too, so a match
                # counts only as a custom record.
                if '"tip_prep/cycle"' in line:
                    r = json.loads(line)
                    pulses += r["type"] == "custom" and r["kind"] == "tip_prep/cycle"
                elif '"run_finished"' in line:
                    r = json.loads(line)
                    outcome, ms = r["outcome"], r["duration"]
        if outcome not in COUNTED:
            continue
        counted += 1
        if outcome == "completed":
            runs.append({"log": name, "pulses": pulses, "minutes": round(ms / 60000, 3)})
    pulsed = [r for r in runs if r["pulses"] > 0]
    result = {
        "source": f"{counted} counted tip_prep logs, {FIRST} to {LAST}",
        "completed": len(runs),
        "without_pulse": len(runs) - len(pulsed),
        "median_pulses": statistics.median(r["pulses"] for r in pulsed),
        "median_minutes": round(statistics.median(r["minutes"] for r in pulsed), 2),
        "runs": runs,
    }
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "..", "data", "run_effort.json"), "w") as f:
        json.dump(result, f, indent=2)
        f.write("\n")
    print({k: v for k, v in result.items() if k != "runs"})


if __name__ == "__main__":
    main(sys.argv[1])
