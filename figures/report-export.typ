// The run figure the report uses: the first entry of `runs.typ` on the
// symlog axis, as page 1 of figures-log.pdf but without the source note.
// Regenerate with
//   typst compile report-export.typ ../report/src/06_validation/fig_run.pdf
//
// The report's dark output has its own copy, in the colours of
// report/theme.typ. That file lies outside this project, so the root moves
// up one level for it:
//   typst compile --root .. --input theme=dark report-export.typ ../report/src/06_validation/fig_run-dark.pdf
#import "@preview/lilaq:0.6.0" as lq
#import "lib.typ": run-figure
#import "runs.typ": runs

#let dark = sys.inputs.at("theme", default: "light") == "dark"

#let width = 12cm
#set page(width: width, height: width * 2 / 3, margin: 3mm)

#let r = runs.at(0)
#let figure-body(prefix) = align(horizon, run-figure(
  // `runs.typ` gives paths from this project's root.
  prefix + r.path,
  trim-front: r.trim-front,
  trim-back: r.trim-back,
  yscale: lq.scale.symlog(threshold: 1.0),
))

#if dark {
  import "/report/theme.typ" as th
  // No page fill: the figure takes the report's paper, whatever it is.
  set page(fill: none)
  set text(fill: th.ink)
  import "/report/plot.typ": plot-style
  show: plot-style
  figure-body("/figures")
} else {
  figure-body("")
}
