// Block diagram of the rusty-tip crate.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: rect

#let architecture-diagram(
  accent: rgb("0267A5"),
  scale: 1.0,
  sx: 5mm,
  sy: 18mm,
) = {
  set text(size: 14pt * scale)
  set par(justify: false)

  let pipe-fill = accent.lighten(85%) // main pipeline
  let side-fill = luma(238) // cross-cutting services
  let backend-fill = accent.lighten(70%) // swappable hardware backends

  let nd(pos, name, body, fill: pipe-fill, w: 33mm, dashed: false) = node(
    pos,
    align(center, body),
    name: name,
    shape: rect,
    corner-radius: 4pt,
    width: w * scale,
    fill: fill,
    stroke: if dashed { (paint: accent, thickness: 1pt, dash: "dashed") } else {
      1pt + accent
    },
    inset: 6pt,
  )

  let tag = body => text(size: 0.78em, body)

  diagram(
    spacing: (sx * scale, sy * scale),
    node-stroke: 1pt + accent,

    nd((0, 1), <config>, [*Config* \ parameters]),
    nd((1, 1), <routine>, [*Routine* \ state machine]),
    nd((2, 1), <actions>, [*Actions* \ bias - motor - scan], w: 40mm),
    nd((3, 1), <controller>, [*Controller* \ interface]),

    nd(
      (4, 1),
      <hardware>,
      [*Instrument* \ #tag[Nanonis - Mock - custom]],
      fill: backend-fill,
      w: 48mm,
    ),

    nd(
      (2.5, 0),
      <machine>,
      [*Machine state* \ preconditions],
      fill: side-fill,
      w: 42mm,
    ),

    nd(
      (1.5, 2),
      <events>,
      [*Event bus* \ GUI - logs],
      fill: side-fill,
      w: 36mm,
    ),
    nd(
      (2.5, 2),
      <analyzers>,
      [*Analyzers* \ pure functions],
      fill: side-fill,
      w: 40mm,
    ),

    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <actions>, "-|>"),
    edge(<actions>, <controller>, "-|>"),
    edge(<controller>, <hardware>, "-|>"),

    edge(<controller>, <machine>, "-|>", tag[queries], label-fill: white),
    edge(<machine>, <actions>, "-|>", tag[guards], label-fill: white),

    edge(<actions>, <events>, "--|>", tag[emits], label-fill: white),
    edge(<actions>, <analyzers>, "--|>", tag[frames], label-fill: white),
  )
}
