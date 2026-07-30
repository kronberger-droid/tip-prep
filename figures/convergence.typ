// Frequency-shift convergence, plotted from real runs.
//
// Data is transcribed from the `StableSignal` results in
//   experiments/tip_prep_20251212_151951.json   (9 pulses, 70.5 s)
//   experiments/tip_prep_20251212_152232.json   (5 pulses, 41.4 s)
// Each point is one `Get stable signal 76` read: 1000 points, accepted only
// once std dev and slope fall under threshold. Both sessions ran on the same
// afternoon with sharp bounds (-2.0, 0.0) Hz.
//
// Regenerate with scripts/scan_logs.py if the runs are ever re-picked.
//
//   #import "figures/convergence.typ": convergence-plot
//   #convergence-plot(accent: accent, scale: 1.0)

#import "@preview/lilaq:0.5.0" as lq

// Read index -> stabilised delta f in Hz. Index 0 is the first read after the
// initial approach, i.e. before any pulse.
#let run-a = (-19.311, -11.271, -12.194, -10.133, -7.366, -10.586, -11.517,
  -3.459, -2.621, -1.290)
#let run-b = (-13.765, -7.125, -11.466, -8.110, -2.664, -0.847)

// Sharp band from the run config: freq shift inside this window counts as sharp.
#let sharp-band = (-2.0, 0.0)

// Defaults are sized for one column of the A0 poster (~380 mm of usable panel
// width), so `scale: 1.0` already fills a panel. Text is set near the poster
// base size rather than a chart-typical 10 pt, otherwise the axis labels are
// unreadable from two metres away.
#let convergence-plot(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 22pt * scale)

  let run-b-color = rgb("B0533A")
  let band-color = rgb("2E7D32")

  let xs-a = range(run-a.len()).map(i => i)
  let xs-b = range(run-b.len()).map(i => i)
  let xmax = run-a.len() - 1

  lq.diagram(
    width: 300mm * scale,
    height: 120mm * scale,
    xlabel: [pulse cycle],
    ylabel: [$Delta f$ (Hz)],
    xlim: (-0.4, xmax + 0.4),
    ylim: (-21, 1.5),
    legend: (position: bottom + right),

    // Sharp band drawn first so both traces sit on top of it.
    lq.fill-between(
      (-1, xmax + 1),
      (sharp-band.at(0), sharp-band.at(0)),
      y2: (sharp-band.at(1), sharp-band.at(1)),
      fill: band-color.transparentize(80%),
      stroke: none,
      z-index: 0,
      label: [sharp band],
    ),

    lq.plot(
      xs-a, run-a,
      stroke: 3pt + accent,
      mark: "o",
      mark-size: 8pt * scale,
      color: accent,
      label: [session 1],
    ),
    lq.plot(
      xs-b, run-b,
      stroke: (paint: run-b-color, thickness: 3pt, dash: "dashed"),
      mark: "s",
      mark-size: 8pt * scale,
      color: run-b-color,
      label: [session 2],
    ),
  )
}
