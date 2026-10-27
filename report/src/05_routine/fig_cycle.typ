// One cycle of the tip-preparation loop as swimlanes, not to scale. Phase
// order and states mirror rusty-tip src/tip_prep/runner.rs (main loop:
// pulse, post-pulse settle, reposition, read_stable) and
// src/action/z_controller.rs (CalibratedApproach, steps 1 to 8).
// STUB: layout only; durations of withdraw, coarse step and approach are
// not measured yet.

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
    ([withdraw], [], 0.9),
    ([coarse step], [1 per axis], 0.9),
    ([approach, landing gate], [], 1.3),
    ([Z-home, wait, centre PLL], [50 nm, 500 ms], 1.5),
    ([re-land, landing gate], [$<= 30$ s], 1.3),
    ([read], [100 samples, 0.1 s], 1.3),
  )

  let label-w = 17mm
  let plot-w = size.width - label-w
  let total = phases.map(p => p.at(2)).sum()
  let cum = (0,)
  for p in phases { cum.push(cum.last() + p.at(2)) }
  // x of phase i at fraction f of its width
  let x(i, f) = label-w + (cum.at(i) + f * phases.at(i).at(2)) / total * plot-w

  let head-h = 9mm
  let lane-h = 7mm
  let gap = 1.5mm
  let lanes = ([Bias], [Tip height], [Z-controller], [Safe-tip], [$Delta f$])
  let lane-y(k) = head-h + 2.5mm + k * (lane-h + gap)
  let height = lane-y(lanes.len())

  // A trace through (phase, fraction, level) points; level 0 is the lane's
  // bottom, 1 its top.
  let trace(k, pts) = {
    let y0 = lane-y(k) + lane-h
    let pt(p) = (x(p.at(0), p.at(1)), y0 - p.at(2) * lane-h)
    place(curve(
      stroke: 1pt + accent,
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
      height: lane-h,
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
        align(center + bottom, [*#p.at(0)* \ #text(fill: luma(90), p.at(1))]),
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
        height: lane-h,
        align(right + horizon, l),
      ))
    }

    // Bias: one pulse at the start, the setpoint bias otherwise.
    trace(0, (
      (0, 0, 0.3), (0, 0.3, 0.3), (0, 0.3, 1), (0, 0.6, 1), (0, 0.6, 0.3),
      (7, 1, 0.3),
    ))

    // Tip height: 0 is the surface, 0.3 Z-home, 1 withdrawn.
    trace(1, (
      (0, 0, 0), (1, 1, 0),
      (2, 0.8, 1), (3, 1, 1),
      (4, 0.8, 0), (5, 0.2, 0),
      (5, 0.4, 0.3), (5, 1, 0.3),
      (6, 0.6, 0), (7, 1, 0),
    ))

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
