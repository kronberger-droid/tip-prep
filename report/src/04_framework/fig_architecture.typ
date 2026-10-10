// Block diagram of the rusty-tip library as of the 0.5 line. Ported from
// poster/figures/architecture.typ, which still shows the machine-state model
// removed in f76a991; here the capability-checked handles take its place.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: rect

#let architecture-diagram(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 8pt * scale)
  set par(justify: false)

  let pipe-fill = accent.lighten(85%) // main pipeline
  let side-fill = luma(238) // cross-cutting services
  let backend-fill = accent.lighten(70%) // swappable hardware backends

  let nd(pos, name, body, fill: pipe-fill, w: 24mm, dashed: false) = node(
    pos,
    align(center, body),
    name: name,
    shape: rect,
    corner-radius: 3pt,
    width: w * scale,
    fill: fill,
    stroke: if dashed { (paint: accent, thickness: 0.7pt, dash: "dashed") } else {
      0.7pt + accent
    },
    inset: 4pt,
  )

  let tag = body => text(size: 0.85em, body)
  let lbl = (label-fill: white)

  diagram(
    spacing: (5mm * scale, 9mm * scale),
    node-stroke: 0.7pt + accent,
    edge-stroke: 0.7pt + accent.darken(10%),

    nd((1, 0), <session>, [*Session* \ #tag[one connection, \ many jobs]], fill: side-fill),

    nd((0, 1), <config>, [*Config* \ #tag[numbers of a run]]),
    nd((1, 1), <routine>, [*Routine* \ #tag[control flow]]),
    nd((2, 1), <handles>, [*Handles* \ #tag[capability check]]),
    nd((3, 1), <actions>, [*Actions* \ #tag[bias, Z, motor, scan]]),
    nd((4, 1), <controller>, [*SpmController* \ #tag[trait]]),

    nd((4, 2), <hardware>, [*Instrument* \ #tag[Nanonis, mock]], fill: backend-fill),
    nd((1, 2), <analyzers>, [*Analyzers*, \ *classifiers*], fill: side-fill),
    nd((2.5, 2), <events>, [*Event bus* \ #tag[log, GUI]], fill: side-fill),

    edge(<session>, <routine>, "-|>", tag[runs], ..lbl),
    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <handles>, "-|>"),
    edge(<handles>, <actions>, "-|>"),
    edge(<actions>, <controller>, "-|>"),
    edge(<controller>, <hardware>, "-|>"),

    edge(<handles>, <events>, "--|>", tag[emits], ..lbl),
    edge(<routine>, <analyzers>, "<|-|>", tag[frames, \ verdicts], ..lbl),
  )
}
