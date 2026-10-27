// Pulse voltage of the linear and stepping strategies, as rusty-tip
// src/tip_prep/pulse_state.rs defines them: `linear_voltage` (#54) and the
// Stepping arm of `update_voltage`. Example values: the linear clamp and
// voltages most linear runs used; stepping on the same 4 to 8 V, illustrative
// since no run used it.
#import "@preview/lilaq:0.6.0" as lq

#let clamp = (-5.0, -1.5)
#let volts = (4.0, 8.0)
#let window = (-1.5, 0.0)

#let linear-voltage(fs) = {
  let (far, near) = clamp
  let (gentle, hard) = volts
  if fs < far or fs > near { hard } else {
    gentle + (near - fs) / (near - far) * (hard - gentle)
  }
}

// Stepping: `steps` treads from the lower to the upper bound, one step after
// `every` cycles without a rise of more than `threshold`, back to the lower
// bound on such a rise. The code compares with the mean of recent readings;
// a scripted sequence gives the same staircase against the last reading.
#let stepping = (steps: 4, every: 2, threshold: 0.5)
#let readings = (
  -6.2, -6.0, -6.3, -6.1, -6.2, -6.0, -6.1, -6.3, -6.2, -6.0, -6.1, -6.2,
  -3.5, -3.6, -3.4, -3.7, -3.5, -3.6,
)

#let stepping-pulses(readings) = {
  let (lo, hi) = volts
  let step = (hi - lo) / stepping.steps
  let v = lo
  let quiet = 0
  let pulses = ()
  let last = none
  for r in readings {
    // The pulse fired this cycle, chosen before its reading.
    pulses.push(v)
    if last != none and r - last > stepping.threshold {
      v = lo
      quiet = 0
    } else if last != none {
      quiet += 1
      if quiet >= stepping.every {
        v = calc.min(v + step, hi)
        quiet = 0
      }
    }
    last = r
  }
  pulses
}

#let strategies-figure(width: 5.6cm, height: 4.2cm) = {
  let (c-read, c-pulse, c-inside, ..) = lq.color.map.okabe-ito
  let guide = (paint: luma(150), thickness: 0.5pt, dash: "dashed")
  set text(size: 8pt)

  // (a) Inside the window the tip counts as sharp and is not pulsed, so the
  // curve breaks there and resumes at the hardest pulse above it.
  let below = range(0, 101).map(i => -8.0 + i * 6.5 / 100)
  let above = (0.0, 2.0)
  let linear = lq.diagram(
    width: width,
    height: height,
    xlabel: [Frequency shift (Hz)],
    ylabel: [Pulse (V)],
    xlim: (-8, 2),
    // A curve, not bars, so the axis need not start at zero.
    ylim: (3, 9),
    yaxis: (ticks: (4, 6, 8)),
    lq.rect(window.at(0), 0%, width: window.at(1) - window.at(0), height: 100%, fill: c-inside.transparentize(75%), stroke: none),
    lq.vlines(clamp.at(0), stroke: guide),
    lq.plot(below, below.map(linear-voltage), mark: none, stroke: 1pt + c-pulse),
    lq.plot(above, above.map(linear-voltage), mark: none, stroke: 1pt + c-pulse),
    lq.place(-0.75, 6, align: center + horizon, text(size: 7pt)[sharp]),
    lq.place(-5.15, 3.6, align: right + horizon, text(size: 7pt, fill: luma(90))[clamp]),
  )

  // (b) A thin reading lane over the pulses, on one cycle axis.
  let cycles = range(1, readings.len() + 1)
  let pulses = stepping-pulses(readings)
  let reset = readings.len() - 5
  let lane = height * 0.32
  let gap = 2mm
  // Tick labels of one width in both lanes, so their axis titles line up.
  let tick(v) = (v, box(width: 1.1em, align(right, [$#v$])))
  let trend = lq.diagram(
    width: width,
    height: lane,
    xlim: (0.3, readings.len() + 0.7),
    ylim: (-7, -2.5),
    xaxis: (format-ticks: none),
    yaxis: (ticks: (tick(-6), tick(-3))),
    ylabel: [$Delta f$ (Hz)],
    lq.plot(cycles, readings, mark: "o", mark-size: 3pt, stroke: 0.8pt + c-read),
    lq.place(reset - 1.4, -4.4, align: right + horizon, text(size: 7pt)[rise]),
  )
  let steps = lq.diagram(
    width: width,
    height: height - lane - gap,
    xlabel: [Cycle],
    ylabel: [Pulse (V)],
    xlim: (0.3, readings.len() + 0.7),
    ylim: (0, 9),
    yaxis: (ticks: (tick(0), tick(4), tick(8))),
    lq.bar(cycles, pulses, width: 0.7, fill: c-pulse),
    lq.place(reset + 0.7, 4.4, align: left + bottom, text(size: 7pt)[reset]),
  )

  grid(
    columns: 2,
    column-gutter: 6mm,
    row-gutter: 2mm,
    align: center + bottom,
    // Right-aligned, so the two lanes' data areas line up whatever their
    // y-labels measure.
    linear, stack(spacing: gap, align(right, trend), align(right, steps)),
    [(a) Linear], [(b) Stepping],
  )
}
