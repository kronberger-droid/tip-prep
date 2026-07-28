// rusty-tip architecture, drawn natively with fletcher.
//
// A deliberately minimal, *landscape* view of the framework in
// `rusty-tip/src`: a config drives the routine, which runs actions against a
// swappable controller; a machine-state guard and an event bus sit above and
// below the actions. Laid out horizontally so it fills a wide panel. Import
// and drop into a panel:
//
//   #import "figures/architecture.typ": architecture-diagram
//   #architecture-diagram()
//
// `accent` keeps it on-palette; `scale` multiplies node size, spacing and
// text together so it stays legible when resized to fit a panel.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect

#let architecture-diagram(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 14pt * scale)

  let pipe-fill = accent.lighten(85%)     // main pipeline
  let side-fill = luma(238)               // cross-cutting services
  let backend-fill = accent.lighten(70%)  // swappable hardware backends

  let nd(pos, name, body, fill: pipe-fill, w: 33mm) = node(
    pos,
    align(center, body),
    name: name,
    shape: rect,
    corner-radius: 4pt,
    width: w * scale,
    fill: fill,
    stroke: 1pt + accent,
    inset: 6pt,
  )

  let tag = body => text(size: 0.78em, body)

  diagram(
    spacing: (12mm * scale, 16mm * scale),
    node-stroke: 1pt + accent,

    // ---- main pipeline (horizontal spine) ----
    nd((0, 1), <config>, [*Config* \ TOML]),
    nd((1.4, 1), <routine>, [*Routine* \ state machine]),
    nd((2.8, 1), <actions>, [*Actions* \ bias · motor · scan]),
    nd((4.2, 1), <controller>, [*Controller* \ `SpmController`]),

    // ---- swappable backends (stacked at the end of the spine) ----
    nd((5.5, 0.4), <nanonis>, [*Nanonis* \ hardware], fill: backend-fill, w: 30mm),
    nd((5.5, 1.6), <mock>, [*Mock* \ offline], fill: backend-fill, w: 30mm),

    // ---- cross-cutting services (above / below the actions) ----
    nd((2.8, 0), <machine>, [*Machine state* \ preconditions], fill: side-fill, w: 40mm),
    nd((2.8, 2), <events>, [*Event bus* \ GUI · logs], fill: side-fill, w: 36mm),

    // ---- flow ----
    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <actions>, "-|>"),
    edge(<actions>, <controller>, "-|>"),
    edge(<controller>, <nanonis>, "-|>"),
    edge(<controller>, <mock>, "-|>"),

    // ---- side wiring (dashed = cross-cutting) ----
    edge(<machine>, <actions>, "--|>", tag[guards]),
    edge(<actions>, <events>, "--|>", tag[emits]),
  )
}
