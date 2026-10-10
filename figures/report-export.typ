// The run figure the report uses: the first entry of `runs.typ` on the
// symlog axis, as page 1 of figures-log.pdf but without the source note.
// Regenerate with
//   typst compile report-export.typ ../report/src/06_validation/fig_run.pdf
#import "@preview/lilaq:0.6.0" as lq
#import "lib.typ": run-figure
#import "runs.typ": runs

#let width = 12cm
#set page(width: width, height: width * 2 / 3, margin: 3mm)

#let r = runs.at(0)
#align(horizon, run-figure(
  r.path,
  trim-front: r.trim-front,
  trim-back: r.trim-back,
  yscale: lq.scale.symlog(threshold: 1.0),
))
