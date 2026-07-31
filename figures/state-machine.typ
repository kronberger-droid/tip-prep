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

  // Phase captions, sat on one baseline under the three parts of the machine so
  // each one lines up with the bullet that explains it. The bullets in the panel
  // read *Pulse and reposition* / *Check* / *Stability* in this order, so the
  // wording has to match verbatim: this is the only thing tying text to figure.
  let phase(pos, body) = node(
    pos,
    text(size: 0.78em, fill: accent.darken(10%), weight: "bold", body),
    inset: 3pt,
  )

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
    node((-0.48, -0.5), text(size: 0.8em, tag[$Delta f$ out of bounds]),
      inset: 2pt),
    edge(<blunt>, <sharp>, "-|>", tag[$Delta f$ in bounds], ..lbl, bend: 22deg),
    edge(<sharp>, <stable>, "-|>", tag[sweep \ passed], ..lbl),

    // Sharp -> Blunt is the *check* rejecting a promotion: a read landed in the
    // band, the repositioned re-read did not. It used to read "Δf drift", from
    // when this edge stood for a failed stability sweep and the panel carried a
    // *Recover* bullet. That bullet is gone, and run 115639 shows this exact
    // rejection happening twice, so the label now describes the check.
    edge(<sharp>, <blunt>, "-|>", tag[$Delta f$ out of bounds], ..lbl, bend: 22deg),

    // ---- which part of the machine each bullet is about ----
    // Tucked against the edges they annotate rather than sat in a row along the
    // bottom, where they read as a detached caption strip. `check` sits inside
    // the lens between the two Blunt <-> Sharp arcs, which is the one spot in the
    // figure that is both empty and unambiguously "the thing these two edges do".
    // Inside the self-loop, which is otherwise dead space. Set over three short
    // lines so it fits the circular interior instead of forcing the loop wider.
    phase((-0.52, 0), [bias pulse \ & \ reposition]),
    phase((0.65, 0), [check]),
    phase((1.95, 0.26), [stability]),
  )
}
