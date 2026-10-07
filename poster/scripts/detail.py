"""Full action-by-action timeline of one run, with pulse voltages and bounds."""
import sys
sys.path.insert(0, str(__import__("pathlib").Path(__file__).parent))
from scan_logs import entries
import json
from datetime import datetime

path = sys.argv[1]
t0 = None
for i, e in enumerate(entries(path)):
    act = e.get("action", "")
    res = e.get("result")
    ts = e.get("start_time")
    t = ""
    if ts:
        d = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        if t0 is None:
            t0 = d
        t = f"{(d - t0).total_seconds():7.1f}s"
    line = f"{i:3d} {t} {act[:78]}"
    extra = ""
    if isinstance(res, dict):
        if "StableSignal" in res:
            s = res["StableSignal"]
            m = s["stability_metrics"]
            extra = (f"  -> df={s['stable_value']:.3f} "
                     f"std={m['std_dev']:.3f} slope={m['slope']:.2e} "
                     f"n={int(m['data_points'])}")
        elif "TipState" in res:
            extra = f"  -> {res['TipState']['shape']}"
        elif "Error" in res:
            extra = f"  -> ERROR {str(res['Error'])[:70]}"
        elif "ExperimentData" in res:
            ed = res["ExperimentData"]
            extra = (f"  -> frames={len(ed['signal_frames'])} "
                     f"dur={ed['total_duration_ms']}ms")
        else:
            extra = "  -> " + list(res.keys())[0]
    elif res == "Success":
        extra = ""
    print(line + extra)
