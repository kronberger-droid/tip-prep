"""Summarise tip-prep experiment logs, tolerating truncated files.

The logs are a pretty-printed JSON array of action records. A run that was
killed mid-write leaves a valid prefix, so decode entries one at a time with
raw_decode and stop at the first failure instead of giving up on the file.
"""
import json
import sys
import glob

dec = json.JSONDecoder()


def entries(path):
    """Yield action records, stopping cleanly at a truncation point."""
    raw = open(path, "rb").read().decode("utf-8", errors="replace")
    i = raw.find("[")
    if i < 0:
        return
    i += 1
    n = 0
    while True:
        while i < len(raw) and raw[i] in " \t\r\n,":
            i += 1
        if i >= len(raw) or raw[i] == "]":
            return
        try:
            obj, i = dec.raw_decode(raw, i)
        except ValueError:
            print(f"    (truncated after {n} entries)")
            return
        n += 1
        yield obj


def summarise(path):
    print("==", path.split("/")[-1])
    df_reads = []      # (index, stable_value)
    states = []        # tip shape sequence
    pulses = []        # pulse actions
    phases = []
    n = 0
    for e in entries(path):
        n += 1
        act = e.get("action", "")
        res = e.get("result")
        if "ulse" in act:
            pulses.append(act)
        if not isinstance(res, dict):
            continue
        if "StableSignal" in res:
            df_reads.append((n, res["StableSignal"]["stable_value"]))
        elif "TipState" in res:
            states.append(res["TipState"]["shape"])
        elif "TipStability" in res:
            phases.append(("stability", json.dumps(res)[:160]))
        elif "Error" in res:
            phases.append(("error", str(res["Error"])[:100]))

    print(f"    entries={n} df_reads={len(df_reads)} pulses={len(pulses)} "
          f"states={len(states)}")
    if df_reads:
        vals = [v for _, v in df_reads]
        print(f"    df min={min(vals):.3f} max={max(vals):.3f} "
              f"first={vals[0]:.3f} last={vals[-1]:.3f} "
              f"distinct={len(set(round(v, 4) for v in vals))}")
        print("    df trace:", [round(v, 2) for v in vals])
    if states:
        print("    states:", " ".join(states))
    if pulses:
        print("    pulses:", pulses[:6], "..." if len(pulses) > 6 else "")
    for kind, txt in phases[:4]:
        print(f"    {kind}: {txt}")
    print()


for p in sorted(glob.glob(sys.argv[1] if len(sys.argv) > 1 else "*.json")):
    summarise(p)
