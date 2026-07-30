// Tip-preparation state machine, drawn natively with fletcher.
//
// The minimal view of `rusty-tip/src/tip_prep/runner.rs`: the tip's quality is
// the state (blunt -> sharp -> stable), and the edges are the routine's
// decisions. Import and drop into a panel:
//
//   #import "figures/state-machine.typ": tip-prep-fsm
//   #tip-prep-fsm()
//
// `accent` keeps the figure on-palette; `scale` multiplies node size, spacing
// and text together so it stays legible when resized to fit a panel.

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: circle

#let tip-prep-fsm(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 16pt * scale, fill: white, weight: "bold")

  let blunt-fill = rgb("B0533A")
  let stable-fill = rgb("2E7D32")

  let st(pos, name, body, fill: accent) = node(
    pos,
    align(center, body),
    name: name,
    shape: circle,
    width: 30mm * scale,
    height: 30mm * scale,
    fill: fill,
    stroke: 1.2pt + fill.darken(15%),
  )

  let lbl = (label-size: 0.8em, label-fill: white)
  let tag = body => text(fill: black, weight: "regular", body)

  diagram(
    spacing: (48mm * scale, 34mm * scale),
    node-stroke: none,
    edge-stroke: 1.1pt + accent.darken(10%),

    // ---- states: the tip's quality ----
    st((0, 0), <blunt>, [Blunt], fill: blunt-fill),
    st((1.3, 0), <sharp>, [Sharp]),
    st((2.6, 0), <stable>, [Stable], fill: stable-fill),

    // ---- forward: pulse until sharp, then confirm stable ----
    // Blunt is the implicit start; round self-loop arcing off its left side
    // (blunt sits at grid origin), label riding the top of the loop.
    edge((-0.28, -0.22), (-0.28, 0.22), "-|>", bend: -145deg),
    node((-0.48, -0.5), text(size: 0.8em, tag[$Delta f$ out of band]),
      inset: 2pt),
    edge(<blunt>, <sharp>, "-|>", tag[$Delta f$ in band], ..lbl, bend: 22deg),
    edge(<sharp>, <stable>, "-|>", tag[sweep \ survived], ..lbl),

    // ---- failure: the sweep moves the apex -> max pulse, back to blunt ----
    edge(<sharp>, <blunt>, "-|>", tag[$Delta f$ drift], ..lbl, bend: 22deg),
  )
}
