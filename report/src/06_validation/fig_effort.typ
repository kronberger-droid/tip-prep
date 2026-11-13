// Pulses and duration of each pulsed completed run, one dot per run. Data:
// data/run_effort.json, written by scripts/run_effort.nu. Runs completed
// without a pulse cannot sit on a log axis and are counted in the caption.
#import "/theme.typ" as th
#import "/plot.typ": plot-style
#import "@preview/lilaq:0.6.0" as lq

#let effort = json("/data/run_effort.json")

// The run of @fig:run, ringed so the two figures can be read together.
#let shown = "tip_prep_20260925_104637.jsonl"

#let effort-figure(width: 10cm, height: 6cm) = {
  show: plot-style
  let (c-run, ..) = lq.color.map.okabe-ito
  let pulsed = effort.runs.filter(r => r.pulses > 0)
  let xs = pulsed.map(r => r.pulses)
  let ys = pulsed.map(r => r.minutes)
  let ring = pulsed.find(r => r.log == shown)
  let guide = (paint: th.grey(150), thickness: 0.5pt, dash: "dashed")

  set text(size: 8pt)
  lq.diagram(
    width: width,
    height: height,
    xscale: "log",
    yscale: "log",
    xlabel: [Pulses until a confirmed sharp tip],
    ylabel: [Run duration (min)],
    xlim: (0.7, 400),
    ylim: (0.4, 60),
    xaxis: (ticks: ((1, [1]), (10, [10]), (100, [100]))),
    yaxis: (ticks: ((1, [1]), (10, [10]))),
    lq.vlines(effort.median_pulses, stroke: guide),
    lq.hlines(effort.median_minutes, stroke: guide),
    lq.scatter(xs, ys, size: 9pt, color: c-run.transparentize(20%)),
    lq.scatter(
      (ring.pulses,),
      (ring.minutes,),
      size: 18pt,
      color: th.ink.transparentize(100%),
      stroke: 0.8pt + th.ink,
    ),
    lq.place(
      ring.pulses * 1.3,
      ring.minutes,
      align: left + horizon,
      [@fig:run],
    ),
    lq.place(effort.median_pulses * 1.08, 50, align: left + top, text(
      fill: th.grey(90),
    )[median]),
    lq.place(300, effort.median_minutes * 1.08, align: right + bottom, text(
      fill: th.grey(90),
    )[median]),
  )
}
