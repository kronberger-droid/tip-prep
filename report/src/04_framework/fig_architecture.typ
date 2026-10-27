// Block diagram of the rusty-tip library as of the 0.5 line, in the
// vocabulary of chapter 3: the session runs jobs through the harness, a
// routine reaches the controller interface only through subsystem handles,
// and backends implement the interface. Ported from
// poster/figures/architecture.typ, which still shows the machine-state model
// removed in f76a991.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: rect

#let architecture-diagram(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 8pt * scale)
  set par(justify: false)

  // Two fills: the software, and the hardware it drives. Dashed and grey is
  // what tip preparation does not use.
  let soft-fill = accent.lighten(85%)
  let hard-fill = accent.lighten(65%)
  let unused-fill = luma(242)

  let nd(pos, name, body, fill: soft-fill, w: 25mm, dashed: false) = node(
    pos,
    align(center, body),
    name: name,
    shape: rect,
    corner-radius: 3pt,
    width: w * scale,
    fill: fill,
    stroke: if dashed { (paint: luma(140), thickness: 0.7pt, dash: "dashed") } else {
      0.7pt + accent
    },
    inset: 4pt,
  )

  let tag = body => text(size: 0.85em, body)
  let lbl = (label-fill: white, label-size: 0.85em)

  diagram(
    spacing: (5mm * scale, 8mm * scale),
    node-stroke: 0.7pt + accent,
    edge-stroke: 0.7pt + accent.darken(10%),

    nd((0, 0), <session>, [*Session* \ #tag[one connection, \ many jobs]]),
    nd((1, 0), <harness>, [*Harness* \ #tag[setup, cleanup, \ exit policy]]),

    nd((0, 1), <config>, [*Configuration* \ #tag[run parameters, \ logged]]),
    nd((1, 1), <routine>, [*Routine* \ #tag[control flow]]),
    nd((2, 1), <handles>, [*Subsystem handles* \ #tag[`rt.bias()`, `rt.z()`, …]], w: 31mm),
    nd((3.5, 1), <interface>, [*Controller interface* \ #tag[`SpmController`]], w: 33mm),

    nd((0, 2), <analyzers>, [*Analyzers, classifiers* \ #tag[not used by \ tip preparation]], fill: unused-fill, dashed: true),
    nd((1.5, 2), <events>, [*Event bus* \ #tag[log, console, workbench]]),
    nd((3, 2), <nanonis>, [*Nanonis backend* \ #tag[nanonis-rs]], w: 28mm),
    nd((4, 2), <mock>, [*Mock backend* \ #tag[scripted tip model]]),

    // Closer than a full row: the TCP edge needs no more room.
    nd((3, 2.8), <instrument>, [*Instrument* \ #tag[Nanonis controller]], fill: hard-fill),

    edge(<session>, <harness>, "-|>", tag[jobs], ..lbl),
    edge(<harness>, <routine>, "-|>", tag[runs], ..lbl),
    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <handles>, "-|>"),
    edge(<handles>, <interface>, "-|>", tag[capability \ check], ..lbl),
    edge(<interface>, <nanonis>, "-|>"),
    edge(<interface>, <mock>, "-|>"),
    edge(<nanonis>, <instrument>, "-|>", tag[TCP], ..lbl),

    // Unlabelled: the caption says what reaches the bus, and labels here
    // collide in the narrow space between the two arrows.
    edge(<routine>, <events>, "--|>"),
    edge(<handles>, <events>, "--|>"),
    edge(<routine>, <analyzers>, "<|-|>", stroke: (paint: luma(140), dash: "dashed")),
  )
}
