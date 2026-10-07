#import "@preview/lilaq:0.6.0" as lq

// Swap the palette here. Roles are taken by position and `..` drops the rest;
// skip a colour with `_`, e.g. `(c-read, _, c-pulse, ..)`.
// Categorical: okabe-ito, petroff6, petroff8, petroff10 (all under lq.color.map).
#let palette = lq.color.map.okabe-ito
#let (c-read, c-pulse, c-inside, c-confirm, ..) = palette

// Series styles, shared by the plots and the hand-built legend.
#let c-window = c-inside.transparentize(75%)
#let read-stroke = 0.8pt
#let mark-r = 2.5pt
#let gap = 2mm

// Lilaq's legend belongs to one diagram, so the row spanning both is plain content.
// Shift an icon so its centre sits at half the cap height, i.e. level with the label.
#let mid(icon) = context {
  let cap = measure[X].height
  let h = measure(icon).height
  box(baseline: h / 2 - cap / 2, icon)
}
#let entry(icon, body) = box[#mid(icon)#h(0.3em)#body]
#let dot(c) = circle(radius: mark-r, fill: c)
#let swatch(c) = rect(width: 1em, height: 0.7em, fill: c)
#let line-dot(c) = box(width: 1.4em, height: 2 * mark-r, {
  place(horizon, line(length: 100%, stroke: read-stroke + c))
  align(center + horizon, circle(radius: mark-r * 0.8, fill: c))
})

#let fmt(v) = str(calc.round(v, digits: 1))

// Lays the reads out on one axis. Confirmation reads get their own slots right
// after the in-window read they check, which pushes every later read right; a
// pulse fired after a rejected confirmation sits on the last confirmation slot.
#let layout-reads(rows) = {
  let out = (reads: (), inside: (), confirm: (), pulses: ())
  let shift = 0
  for r in rows {
    let x = float(r.cycle) + shift
    let y = float(r.freq_shift_hz)
    out.reads.push((x, y))
    if r.in_window == "true" { out.inside.push((x, y)) }
    let checks = (r.confirm1_hz, r.confirm2_hz, r.confirm3_hz).filter(c => (
      c != ""
    ))
    for (i, c) in checks.enumerate() { out.confirm.push((x + i + 1, float(c))) }
    if r.pulse_v != "" { out.pulses.push((x + checks.len(), float(r.pulse_v))) }
    shift += checks.len()
  }
  out
}

// One figure per run: frequency-shift reads above the pulse sequence.
// `path` is root-relative (leading `/`) since `csv` resolves against this file.
#let run-figure(path, trim-front: 0, trim-back: 0) = {
  assert(
    type(trim-front) == int
      and type(trim-back) == int
      and trim-front >= 0
      and trim-back >= 0,
    message: "trim-front and trim-back must be non-negative integers",
  )
  let all = csv(path, row-type: dictionary)
  assert(
    trim-front + trim-back < all.len(),
    message: "trimming "
      + str(trim-front + trim-back)
      + " of "
      + str(all.len())
      + " rows leaves nothing in "
      + path,
  )
  let rows = all.slice(trim-front, all.len() - trim-back)
  let window-lo = float(rows.first().window_lo_hz)
  let window-hi = float(rows.first().window_hi_hz)

  let d = layout-reads(rows)
  let xs = d.reads.map(p => p.first()) + d.confirm.map(p => p.first())
  let xlim = (calc.min(..xs) - 1, calc.max(..xs) + 1)

  let amps = d.pulses.map(p => calc.abs(p.last())).dedup().sorted()
  let bias = if amps.len() == 0 { none } else if amps.len() <= 2 {
    amps.map(v => [±#fmt(v)]).join(" / ")
  } else [±#fmt(amps.first())–#fmt(amps.last())]
  let vmax = calc.max(0, ..amps)

  let legend-row = {
    set text(size: 0.8em)
    (
      entry(swatch(c-window))[sharp window],
      entry(line-dot(c-read))[read],
      if d.inside.len() > 0 { entry(dot(c-inside))[in window] },
      if d.confirm.len() > 0 { entry(dot(c-confirm))[confirmation] },
      if bias != none { entry(swatch(c-pulse))[pulse (#bias V)] },
    )
      .filter(e => e != none)
      .join(h(0.9em))
  }

  // Equal-width y tick labels so both ylabels sit at the same x.
  show: lq.show_(lq.tick-label.with(kind: "y"), it => box(width: 1.6em, align(
    right,
    it,
  )))

  stack(
    spacing: gap,
    lq.diagram(
      width: 100%,
      height: 3.8cm,
      xlim: xlim,
      xaxis: (format-ticks: none),
      ylabel: [frequency shift (Hz)],
      legend: none,
      lq.rect(
        0%,
        window-lo,
        width: 100%,
        height: window-hi - window-lo,
        fill: c-window,
        stroke: none,
      ),
      lq.plot(
        d.reads.map(p => p.first()),
        d.reads.map(p => p.last()),
        mark-size: 2 * mark-r * 0.8,
        stroke: read-stroke,
        color: c-read,
      ),
      lq.plot(
        d.inside.map(p => p.first()),
        d.inside.map(p => p.last()),
        stroke: none,
        mark-size: 2 * mark-r,
        color: c-inside,
      ),
      lq.plot(
        d.confirm.map(p => p.first()),
        d.confirm.map(p => p.last()),
        stroke: none,
        mark-size: 2 * mark-r,
        color: c-confirm,
      ),
    ),
    lq.diagram(
      width: 100%,
      height: 1.3cm,
      xlim: xlim,
      xlabel: [cycle],
      ylabel: [pulse (V)],
      yaxis: (ticks: (-vmax, 0, vmax).dedup()),
      lq.bar(
        d.pulses.map(p => p.first()),
        d.pulses.map(p => p.last()),
        fill: c-pulse,
      ),
      // Centred on the data area rather than the whole figure width. Lilaq
      // counts placed content toward the diagram's bounds, so the legend gets
      // a zero-width footprint (its height still reserves the gap) and is
      // drawn at its natural width, overflowing that point on both sides.
      lq.place(50%, 0%, align: bottom, pad(bottom: gap, context {
        let size = measure(legend-row)
        box(width: 0pt, height: size.height, place(
          center + bottom,
          box(width: size.width, legend-row),
        ))
      })),
    ),
  )
}
