// Plot styling the theme needs: lilaq's grid, spines and legend carry their
// own greys, which the dark output has to restate. Used as
// `show: plot-style` in a figure function; it does nothing on paper.
#import "@preview/lilaq:0.6.0" as lq
#import "theme.typ" as th

#let plot-style(body) = {
  if not th.dark { return body }
  show: lq.set-grid(stroke: 0.5pt + th.grey(204))
  show: lq.set-spine(stroke: th.ink)
  show: lq.set-legend(fill: th.paper.transparentize(20%), stroke: 0.5pt + th.grey(128))
  body
}
