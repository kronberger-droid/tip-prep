// Tip-preparation FSM, mirrors rusty-tip/src/tip_prep/runner.rs.
// Ported from poster/figures/state-machine.typ, which sizes for A0; `scale`
// here is relative to the report's body text instead.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: circle

#let tip-prep-fsm(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 9pt * scale, fill: white, weight: "bold")
  set par(justify: false)

  let blunt-fill = rgb("B0533A")
  let stable-fill = rgb("2E7D32")

  let st(pos, name, body, fill: accent) = node(
    pos,
    align(center, body),
    name: name,
    shape: circle,
    width: 16mm * scale,
    height: 16mm * scale,
    fill: fill,
    stroke: 0.8pt + fill.darken(15%),
  )

  let lbl = (label-size: 0.8em, label-fill: white)
  let tag = body => text(fill: black, weight: "regular", body)

  let phase(pos, body) = node(
    pos,
    text(size: 0.78em, fill: accent.darken(10%), weight: "bold", body),
    inset: 2pt,
  )

  diagram(
    spacing: (26mm * scale, 18mm * scale),
    node-stroke: none,
    edge-stroke: 0.8pt + accent.darken(10%),

    st((0, 0), <blunt>, [Blunt], fill: blunt-fill),
    st((1.3, 0), <sharp>, [Sharp]),
    st((2.6, 0), <stable>, [Stable], fill: stable-fill),

    edge((-0.28, -0.22), (-0.28, 0.22), "-|>", bend: -145deg),
    node((-0.48, -0.5), text(size: 0.8em, tag[$Delta f$ out of bounds]), inset: 2pt),
    edge(<blunt>, <sharp>, "-|>", tag[$Delta f$ in bounds], ..lbl, bend: 22deg),
    edge(<sharp>, <stable>, "-|>", tag[sweep \ passed], ..lbl),

    edge(<sharp>, <blunt>, "-|>", tag[$Delta f$ out of bounds], ..lbl, bend: 22deg),

    phase((-0.52, 0), [bias pulse \ & \ reposition]),
    phase((0.65, 0), [sharpness \ check]),
    phase((1.95, 0.26), [stability \ test]),
  )
}
