# Tip-prep figures

Vector figures of individual tip-prep runs, for editing in Inkscape.

## Data

One CSV per run, one row per cycle. Copied from `/run/media/kronberger/DATA/Tip Prep/Plots/`,
where the source `.jsonl` logs and quick-look PNGs live.

- `data/selected/`: the three short runs picked for the size-restricted figure
  - `2026-09-17_1220_success_22pulses_persistent_blunt_tip.csv` (first choice)
  - `2026-09-23_0955_success_13pulses_5V_tight_window_fine_tuning.csv`
  - `2026-09-18_1343_success_11pulses_false_sharp_rejected_then_confirmed.csv`
- `data/long-successes/`: the 11 runs from 2026-09-25 to 2026-10-06 that ended with a confirmed
  sharp tip after more than 5 minutes

| column | meaning |
|---|---|
| `cycle` | pulses fired before this read; row 0 is the read right after the approach |
| `t_s` | seconds since the run started, at the read |
| `freq_shift_hz` | the frequency shift read after the reposition |
| `in_window` | that read is inside the sharp window |
| `pulse_v` | the pulse this read led to, sign included; blank if none followed |
| `confirm1_hz` .. `confirm3_hz` | the confirmation reads after an in-window read; blank otherwise |
| `confirmed` | all three confirmation reads stayed in the window; `false` if one fell out (the routine then pulses again) |
| `stability_final_hz`, `stable` | the read after the bias-sweep stability check and its verdict, where one ran |
| `window_lo_hz`, `window_hi_hz` | the sharp window, repeated on every row |

A read of ±76.29 Hz is the PLL range limit, not a measurement.
