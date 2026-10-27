"""Median duration of each phase of one tip-preparation cycle, for fig_cycle.

Reads the run logs the report counts (tip_prep_*.jsonl from 2026-09-15 to
2026-10-06 whose run finished `completed` or `stopped_by_user`, as in
src/06_validation) and writes data/cycle_durations.json.

Only calibrated approaches that re-land through the Z loop (`z_controller_set`
between the two landing gates) are used, since that is the code path the
figure draws; earlier revisions re-landed with a second auto-approach.

Durations in the logs are milliseconds.

Usage:
    python3 scripts/cycle_durations.py "/run/media/kronberger/DATA/Tip Prep/Experiments"
"""
import json
import os
import statistics
import sys

FIRST, LAST = "20260915", "20261006"
COUNTED = ("completed", "stopped_by_user")


def counted_logs(root):
    for name in sorted(os.listdir(root)):
        if not (name.startswith("tip_prep_") and name.endswith(".jsonl")):
            continue
        if not FIRST <= name[9:17] <= LAST:
            continue
        with open(os.path.join(root, name)) as f:
            records = [json.loads(line) for line in f]
        end = [r for r in records if r["type"] == "run_finished"]
        if end and end[0]["outcome"] in COUNTED:
            yield name, records


def phases(records):
    """Durations of one cycle's phases, one dict per reposition."""
    pulses = [r["duration"] for r in records
              if r["type"] == "action_completed" and r["action"] == "bias_pulse"]
    reads = [r["duration"] for r in records
             if r["type"] == "action_completed" and r["action"] == "read_stable_signal"]
    cycles = []
    current = None
    for r in records:
        if r["type"] == "action_started" and r["action"] == "reposition" and r["depth"] == 0:
            current = []
        elif current is not None and r["type"] == "action_completed":
            if r["action"] == "reposition" and r["depth"] == 0:
                cycles.append(current)
                current = None
            else:
                current.append((r["action"], r["depth"], r["duration"]))
    out = []
    for steps in cycles:
        top = {a: d for a, dp, d in steps if dp == 1 and a in ("withdraw", "move_motor_3d")}
        inner = [(a, d) for a, dp, d in steps if dp == 2]
        names = [a for a, _ in inner]
        if "z_controller_set" not in names or names.count("settle_on_setpoint") != 2:
            continue
        gates = [d for a, d in inner if a == "settle_on_setpoint"]
        z_set = names.index("z_controller_set")
        out.append({
            "withdraw": top.get("withdraw"),
            "coarse_step": top.get("move_motor_3d"),
            "approach": next(d for a, d in inner if a == "auto_approach") + gates[0],
            "home": sum(d for a, d in inner[:z_set]
                        if a in ("z_home", "wait", "center_freq_shift", "safe_tip_set")),
            "reland": inner[z_set][1] + gates[1],
        })
    return pulses, reads, out


def main(root):
    pulses, reads, cycles, runs = [], [], [], 0
    for _, records in counted_logs(root):
        p, r, c = phases(records)
        pulses += p
        reads += r
        cycles += c
        runs += 1
    med = lambda xs: round(statistics.median(x for x in xs if x is not None), 1)
    result = {
        "source": f"{runs} counted tip_prep logs, {FIRST} to {LAST}",
        "cycles": len(cycles),
        "median_ms": {
            "pulse": med(pulses),
            "withdraw": med(c["withdraw"] for c in cycles),
            "coarse_step": med(c["coarse_step"] for c in cycles),
            "approach": med(c["approach"] for c in cycles),
            "home": med(c["home"] for c in cycles),
            "reland": med(c["reland"] for c in cycles),
            "read": med(reads),
        },
    }
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "..", "data", "cycle_durations.json"), "w") as f:
        json.dump(result, f, indent=2)
        f.write("\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
