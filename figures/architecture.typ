// rusty-tip architecture, drawn natively with fletcher.
//
// A deliberately minimal, *landscape* view of the framework in
// `rusty-tip/src`. The spine is the data path: a config drives the routine,
// which runs actions against a swappable controller.
//
// The arc above the spine is the safety loop, and its direction matters. The
// tracked machine state is not a free-floating registry: when an action needs
// a field that is Unknown, `executor.rs::enforce_preconditions` auto-runs a
// side-effect-free Query action against the *controller* and writes the answer
// back into the state (`apply_to_state`). So the controller is the source of
// truth, the state is the cached model of it, and the state is what refuses
// the action. Drawing it Controller -> Machine state -> Actions keeps that
// order honest.
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
  // Node bodies are two or three words wide. Justification stretches those into
  // word-gap canyons ("implement    the / trait"), so turn it off here. The
  // poster-wide `par(justify: true)` is meant for prose, not diagram labels.
  set par(justify: false)

  let pipe-fill = accent.lighten(85%)     // main pipeline
  let side-fill = luma(238)               // cross-cutting services
  let backend-fill = accent.lighten(70%)  // swappable hardware backends

  let nd(pos, name, body, fill: pipe-fill, w: 33mm, dashed: false) = node(
    pos,
    align(center, body),
    name: name,
    shape: rect,
    corner-radius: 4pt,
    width: w * scale,
    fill: fill,
    stroke: if dashed { (paint: accent, thickness: 1pt, dash: "dashed") }
      else { 1pt + accent },
    inset: 6pt,
  )

  let tag = body => text(size: 0.78em, body)

  diagram(
    spacing: (11.5mm * scale, 15mm * scale),
    node-stroke: 1pt + accent,

    // ---- main pipeline (horizontal spine) ----
    nd((0, 1), <config>, [*Config* \ parameters]),
    nd((1.4, 1), <routine>, [*Routine* \ state machine]),
    // Wider than the other spine nodes so the subtitle stays on one line.
    nd((2.8, 1), <actions>, [*Actions* \ bias · motor · scan], w: 40mm),
    // Subtitle is "one interface", not the type name: `SpmController` under
    // *Controller* just restated the box. Called "interface" rather than "trait"
    // because the audience is SPM people, not Rust people. It also keeps this
    // node two lines tall like the rest of the spine.
    nd((4.2, 1), <controller>, [*Controller* \ one interface]),

    // ---- swappable backends: one interface, three implementations ----
    // The third is dashed on purpose: it is the invitation, not a shipped
    // backend.
    nd((5.5, 0.15), <nanonis>, [*Nanonis* \ hardware], fill: backend-fill, w: 31mm),
    nd((5.5, 1), <mock>, [*Mock* \ offline replay], fill: backend-fill, w: 31mm),
    // Subtitle kept to roughly the length of "offline replay" so all three
    // backends are two lines tall and the column stays level. "implement the
    // trait" wrapped to three and made the row ragged.
    nd((5.5, 1.85), <other>, [*Your SPM* \ #tag[your backend]],
      fill: white, w: 31mm, dashed: true),

    // ---- the safety loop, above the spine ----
    nd((3.5, 0), <machine>, [*Machine state* \ preconditions], fill: side-fill, w: 42mm),

    // ---- observability, below the spine ----
    nd((2.8, 2), <events>, [*Event bus* \ GUI · logs], fill: side-fill, w: 36mm),

    // ---- flow ----
    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <actions>, "-|>"),
    edge(<actions>, <controller>, "-|>"),
    edge(<controller>, <nanonis>, "-|>"),
    edge(<controller>, <mock>, "-|>"),
    edge(<controller>, <other>, "-|>"),

    // ---- safety loop: the controller is queried for the truth, the tracked
    // state caches it, and the state is what blocks the action ----
    edge(<controller>, <machine>, "-|>", tag[queries], label-fill: white),
    edge(<machine>, <actions>, "-|>", tag[guards], label-fill: white),

    // ---- observability (dashed = cross-cutting) ----
    edge(<actions>, <events>, "--|>", tag[emits]),
  )
}
