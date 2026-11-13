// Tip-preparation FSM, mirrors rusty-tip/src/tip_prep/runner.rs.
// Ported from poster/figures/state-machine.typ, which sizes for A0; `scale`
// here is relative to the report's body text instead.
#import "/theme.typ" as th
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: circle

#let tip-prep-fsm(accent: th.accent, scale: 1.0) = {
  set text(size: 9pt * scale, fill: th.on-fill, weight: "bold")
  set par(justify: false)

  let blunt-fill = th.blunt
  let stable-fill = th.stable

  let st(pos, name, body, fill: accent) = node(
    pos,
    align(center, body),
    name: name,
    shape: circle,
    width: 16mm * scale,
    height: 16mm * scale,
    fill: fill,
    stroke: 0.8pt + th.shade(fill, 15%),
  )

  let lbl = (label-size: 0.8em, label-fill: th.paper)
  let tag = body => text(fill: th.ink, weight: "regular", body)

  let phase(pos, body) = node(
    pos,
    text(size: 0.78em, fill: th.shade(accent, 10%), weight: "bold", body),
    inset: 2pt,
  )

  diagram(
    spacing: (26mm * scale, 18mm * scale),
    node-stroke: none,
    edge-stroke: 0.8pt + th.shade(accent, 10%),

    st((0, 0), <blunt>, [Blunt], fill: blunt-fill),
    st((1.3, 0), <sharp>, [Sharp]),
    st((2.6, 0), <stable>, [Stable], fill: stable-fill),

    edge((-0.28, -0.22), (-0.28, 0.22), "-|>", bend: -145deg),
    node(
      (-0.48, -0.5),
      text(size: 0.8em, tag[$Delta f$ out of bounds]),
      inset: 2pt,
    ),
    edge(<blunt>, <sharp>, "-|>", tag[$Delta f$ in bounds], ..lbl, bend: 22deg),
    edge(<sharp>, <stable>, "-|>", tag[sweep \ passed], ..lbl),

    edge(
      <sharp>,
      <blunt>,
      "-|>",
      tag[$Delta f$ out of bounds],
      ..lbl,
      bend: 22deg,
    ),

    phase((-0.52, 0), [bias pulse \ & \ reposition]),
    phase((0.65, 0), [sharpness \ check]),
    phase((1.95, 0.26), [stability \ test]),
  )
}
