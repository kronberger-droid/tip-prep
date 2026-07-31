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

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: rect

#let architecture-diagram(accent: rgb("0267A5"), scale: 1.0, sx: 7mm, sy: 18mm) = {
  set text(size: 14pt * scale)
  // Node bodies are two or three words wide. Justification stretches those into
  // word-gap canyons ("implement    the / trait"), so turn it off here. The
  // poster-wide `par(justify: true)` is meant for prose, not diagram labels.
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
    // `spacing.x` is the *gap* between adjacent columns, so integer coordinates
    // give equal gaps no matter how wide the nodes are. The spine used to sit on
    // 0 / 1.4 / 2.8 / 4.2 / 5.6, and a fractional step is a fraction of a column
    // pitch set by the widest node, so the visible gaps came out uneven: wide
    // after `Config`, tight before `Hardware`. Keep the spine on integers.
    spacing: (sx * scale, sy * scale),
    node-stroke: 1pt + accent,

    // ---- main pipeline (horizontal spine) ----
    nd((0, 1), <config>, [*Config* \ parameters]),
    nd((1, 1), <routine>, [*Routine* \ state machine]),
    // Wider than the other spine nodes so the subtitle stays on one line.
    nd((2, 1), <actions>, [*Actions* \ bias · motor · scan], w: 40mm),
    // Subtitle is "one interface", not the type name: `SpmController` under
    // *Controller* just restated the box. Called "interface" rather than "trait"
    // because the audience is SPM people, not Rust people. It also keeps this
    // node two lines tall like the rest of the spine.
    nd((3, 1), <controller>, [*Controller* \ interface]),

    // ---- the backend: one node, options listed inside ----
    // This was three stacked boxes (Nanonis / Mock / Your SPM) with an arrow
    // each, then briefly three boxes inside an enclosing group. Both read as
    // three subsystems the controller talks to, which is wrong: they are
    // interchangeable implementations of the one interface and exactly one is
    // live per run. One node with the options listed says that directly, and it
    // collapses a 3-row column into a single spine node.
    // Two things were given up here, both deliberately: "Mock / offline replay"
    // (its subtitle now just names it) and the dashed border that marked
    // `Your SPM` as an invitation rather than a shipped driver. The invitation
    // now lives only in the *One interface, any instrument* bullet.
    nd(
      (4, 1),
      <hardware>,
      [*Hardware* \ #tag[Nanonis · Mock · yours]],
      fill: backend-fill,
      w: 42mm,
    ),

    // ---- the safety loop, above the spine ----
    nd(
      (2.5, 0),
      <machine>,
      [*Machine state* \ preconditions],
      fill: side-fill,
      w: 42mm,
    ),

    // ---- cross-cutting services, below the spine ----
    nd(
      (1.5, 2),
      <events>,
      [*Event bus* \ GUI · logs],
      fill: side-fill,
      w: 36mm,
    ),
    // Analyzers are **not** actions, and the diagram says so by keeping them off
    // the spine. `Analyzer` is its own trait, `analyze(&AnalyzerInput) ->
    // AnalyzerOutput`, with no `ActionContext` and no hardware. What runs one in
    // a routine is a separate adapter, `RunAnalyzer`, which *is* an `Action`
    // wrapping an `Arc<dyn Analyzer>`: it pulls the frame `GrabScanFrame` left in
    // the `DataStore` and writes the verdict back under the analyzer's name.
    // That indirection is exactly why the same detector serves the live loop and
    // an archived run, which is what the Framework bullet claims. Drawing them as
    // custom actions would delete the reason the claim is true.
    nd(
      (2.5, 2),
      <analyzers>,
      [*Analyzers* \ pure functions],
      fill: side-fill,
      w: 40mm,
    ),

    // ---- flow ----
    edge(<config>, <routine>, "-|>"),
    edge(<routine>, <actions>, "-|>"),
    edge(<actions>, <controller>, "-|>"),
    edge(<controller>, <hardware>, "-|>"),

    // ---- safety loop: the controller is queried for the truth, the tracked
    // state caches it, and the state is what blocks the action ----
    edge(<controller>, <machine>, "-|>", tag[queries], label-fill: white),
    edge(<machine>, <actions>, "-|>", tag[guards], label-fill: white),

    // ---- cross-cutting, both dashed: neither is on the data path ----
    edge(<actions>, <events>, "--|>", tag[emits], label-fill: white),
    edge(<actions>, <analyzers>, "--|>", tag[frames], label-fill: white),
  )
}
