// Histogram of the accepted frequency-shift readings, split by the gates.
// Data: data/readings.json, written by scripts/readings.py. Colours follow
// figures/lib.typ: blue for readings, orange for the second series, the
// sharp window in transparent green.
#import "@preview/lilaq:0.6.0" as lq

#let readings = json("/data/readings.json")

#let readings-figure(width: 12cm, height: 6cm) = {
  let (c-read, c-fail, c-inside, ..) = lq.color.map.okabe-ito
  let w = readings.bin_width_hz
  let xs = readings.bin_starts_hz.map(s => s + w / 2)
  let passed = readings.passed
  let both = passed.zip(readings.failed).map(((p, f)) => p + f)
  let peak = calc.max(..both)
  // The bins holding the two range limits, by their centre.
  let spike(x) = both.at(xs.position(c => calc.abs(c - x) < w / 2))

  set text(size: 8pt)
  lq.diagram(
    width: width,
    height: height,
    xlabel: [Frequency shift (Hz)],
    ylabel: [Readings per #w Hz],
    xlim: (-82, 82),
    ylim: (0, peak * 1.15),
    legend: (position: top + right),
    // The window most runs used (@tab:run-params).
    lq.rect(-1.5, 0%, width: 1.5, height: 100%, fill: c-inside.transparentize(75%), stroke: none, label: [sharp window]),
    lq.bar(xs, passed, width: w * 0.85, fill: c-read, label: [passed the gates]),
    // A bar runs from `base` up to its value, so the stacked one ends at the
    // total and not at its own count.
    lq.bar(xs, both, base: passed, width: w * 0.85, fill: c-fail, label: [failed every retry]),
    lq.place(-78, spike(-77) + peak * 0.03, align: left + bottom, [$-76.29$ Hz]),
    lq.place(78, spike(77) + peak * 0.03, align: right + bottom, [$+76.29$ Hz]),
  )
}
