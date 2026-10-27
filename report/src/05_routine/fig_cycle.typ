// One cycle of the tip-preparation loop as swimlanes, not to scale. Phase
// order and states mirror rusty-tip src/tip_prep/runner.rs (main loop:
// pulse, post-pulse settle, reposition, read_stable) and
// src/action/z_controller.rs (CalibratedApproach, steps 1 to 8). Pulse and
// settle carry their configured defaults; the other phases carry the medians
// in data/cycle_durations.json, written by scripts/cycle_durations.py.

#let durations = json("/data/cycle_durations.json").median_ms

// Seconds to two significant figures, as a label. `approx` marks a phase
// whose length a gate decides, so its median is no fixed time.
#let secs(ms, approx: false) = {
  let s = ms / 1000
  let digits = if s >= 1 { 1 } else { 2 }
  [#if approx { sym.tilde.op }#calc.round(s, digits: digits) s]
}

#let cycle-timeline(accent: rgb("0267A5")) = layout(size => {
  set text(size: 7pt)
  set par(justify: false)

  let on-fill = accent.lighten(70%)
  let off-fill = luma(235)
  let warn-fill = rgb("B0533A").lighten(70%)

  // (name, duration label, relative width)
  let phases = (
    ([pulse], [50 ms], 0.8),
    ([settle], [1 s], 0.9),
    ([withdraw], secs(durations.withdraw), 0.9),
    ([coarse step], secs(durations.coarse_step), 0.9),
    ([approach, landing gate], secs(durations.approach, approx: true), 1.3),
    ([Z-home, centre PLL], secs(durations.home), 1.5),
    ([re-land, landing gate], secs(durations.reland, approx: true), 1.3),
    ([read], secs(durations.read, approx: true), 1.3),
  )

  let label-w = 17mm
  let plot-w = size.width - label-w
  let total = phases.map(p => p.at(2)).sum()
  let cum = (0,)
  for p in phases { cum.push(cum.last() + p.at(2)) }
  // x of phase i at fraction f of its width
  let x(i, f) = label-w + (cum.at(i) + f * phases.at(i).at(2)) / total * plot-w

  let head-h = 9mm
  let gap = 1.5mm
  let lanes = ([Bias], [Tip height], [Z-controller], [Safe-tip], [$Delta f$])
  // Tip height gets twice the room: it carries three heights of very
  // different size.
  let lane-hs = (7mm, 14mm, 7mm, 7mm, 7mm)
  let lane-h(k) = lane-hs.at(k)
  let lane-y(k) = head-h + 2.5mm + lane-hs.slice(0, k).sum(default: 0mm) + k * gap
  let height = lane-y(lanes.len())

  // A trace through (phase, fraction, level) points; level 0 is the lane's
  // bottom, 1 its top.
  let trace(k, pts, dash: none) = {
    let y0 = lane-y(k) + lane-h(k)
    let pt(p) = (x(p.at(0), p.at(1)), y0 - p.at(2) * lane-h(k))
    place(curve(
      stroke: (paint: accent, thickness: 1pt, dash: dash),
      curve.move(pt(pts.first())),
      ..pts.slice(1).map(p => curve.line(pt(p))),
    ))
  }

  // A state bar from phase a to phase b inclusive.
  let state(k, a, b, body, fill) = place(
    dx: x(a, 0),
    dy: lane-y(k),
    box(
      width: x(b, 1) - x(a, 0),
      height: lane-h(k),
      fill: fill,
      stroke: 0.4pt + white,
      align(center + horizon, body),
    ),
  )

  box(width: size.width, height: height, {
    // Phase headers and dividers.
    for (i, p) in phases.enumerate() {
      place(dx: x(i, 0), dy: 0pt, box(
        width: x(i, 1) - x(i, 0),
        height: head-h,
        align(center + bottom, text(size: 6pt)[*#p.at(0)* \ #text(fill: luma(90), p.at(1))]),
      ))
      place(line(
        start: (x(i, 0), head-h),
        end: (x(i, 0), height),
        stroke: (paint: luma(180), thickness: 0.4pt, dash: "dashed"),
      ))
    }

    // Lane labels.
    for (k, l) in lanes.enumerate() {
      place(dx: 0pt, dy: lane-y(k), box(
        width: label-w - 2mm,
        height: lane-h(k),
        align(right + horizon, l),
      ))
    }

    // Bias: one pulse at the start, the setpoint bias otherwise.
    trace(0, (
      (0, 0, 0.3), (0, 0.3, 0.3), (0, 0.3, 1), (0, 0.6, 1), (0, 0.6, 0.3),
      (7, 1, 0.3),
    ))

    // Tip height: 0 is the surface, 0.08 Z-home (50 nm), 0.5 the piezo
    // withdrawn, 0.95 after the coarse step's Z retract (`z_retract`, -3 by
    // default). The coarse retract is far larger than the rest, so the two
    // transitions to and from it break in the middle, not to scale.
    let (home, withdrawn, coarse) = (0.08, 0.5, 0.95)
    // Where the approach, from the coarse height to the surface over 0.8 of
    // its phase, passes the withdrawn level.
    let rejoin = 0.8 * (coarse - withdrawn) / coarse
    // A transition from a to b, solid with a dotted stretch in its middle.
    let broken(k, a, b) = {
      let y0 = lane-y(k) + lane-h(k)
      let pt(p) = (x(p.at(0), p.at(1)), y0 - p.at(2) * lane-h(k))
      let (pa, pb) = (pt(a), pt(b))
      let at(t) = (pa.at(0) + t * (pb.at(0) - pa.at(0)), pa.at(1) + t * (pb.at(1) - pa.at(1)))
      let seg(t0, t1, dash) = place(line(
        start: at(t0),
        end: at(t1),
        stroke: (paint: accent, thickness: 1pt, dash: dash, cap: "round"),
      ))
      seg(0, 0.38, none)
      seg(0.38, 0.62, (0pt, 2.2pt))
      seg(0.62, 1, none)
    }
    trace(1, (
      (0, 0, 0), (1, 1, 0),
      (2, 0.8, withdrawn), (3, 0.2, withdrawn),
    ))
    broken(1, (3, 0.2, withdrawn), (3, 0.8, coarse))
    trace(1, ((3, 0.8, coarse), (3, 1, coarse)))
    broken(1, (3, 1, coarse), (4, rejoin, withdrawn))
    trace(1, (
      (4, rejoin, withdrawn), (4, 0.8, 0), (5, 0.2, 0),
      (5, 0.4, home), (5, 1, home),
      (6, 0.6, 0), (7, 1, 0),
    ))
    place(
      dx: x(5, 0.4),
      dy: lane-y(1) + lane-h(1) * (1 - home) - 8pt,
      box(width: x(5, 1) - x(5, 0.4), align(center, text(size: 6pt, fill: luma(90))[50 nm])),
    )

    state(2, 0, 0, [hold], warn-fill)
    state(2, 1, 1, [on], on-fill)
    state(2, 2, 3, [off], off-fill)
    state(2, 4, 4, [on], on-fill)
    state(2, 5, 5, [off], off-fill)
    state(2, 6, 7, [on], on-fill)

    state(3, 0, 4, [off], off-fill)
    state(3, 5, 5, [on], on-fill)
    state(3, 6, 7, [off], off-fill)

    state(4, 5, 5, [centred], off-fill)
    state(4, 7, 7, [gated, \ up to 3 retries], on-fill)
  })
})
