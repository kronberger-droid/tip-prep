// Delta f trace of two runs. All numbers come from traces.json, none inline.
#import "@preview/lilaq:0.5.0" as lq

#let traces = json("traces.json")
#let run-pass = traces.runs.at(0)
#let run-fail = traces.runs.at(1)

#let band-lo = calc.max(..traces.runs.map(r => r.sharp_bounds.at(0)))
#let band-shared = calc.min(..traces.runs.map(r => r.sharp_bounds.at(1)))
#let band-hi = calc.max(..traces.runs.map(r => r.sharp_bounds.at(1)))

#let convergence-plot(accent: rgb("0267A5"), scale: 1.0) = {
  set text(size: 22pt * scale)

  let fail-color = rgb("B0533A")
  let band-color = rgb("2E7D32")
  let check-color = rgb("6A3D9A")

  let trace-line(c) = (paint: c.transparentize(72%), thickness: 2pt * scale)

  let rail = 76.29
  let clean(ys) = {
    let keep = range(ys.len()).filter(i => {
      calc.abs(calc.abs(ys.at(i)) - rail) > 0.02
    })
    (keep, keep.map(i => ys.at(i)))
  }

  let split(run, want-check) = {
    let (xs, ys) = clean(run.df)
    let keep = range(xs.len()).filter(i => {
      let is-check = run.phase.at(xs.at(i)) != "loop"
      if want-check { is-check } else { not is-check }
    })
    (keep.map(i => xs.at(i)), keep.map(i => ys.at(i)))
  }

  let post-note(run, x, y) = lq.place(
    x,
    y,
    align: top + right,
    text(size: 0.8em, fill: check-color)[
      after sweep \
      #str(calc.round(run.stability.at(0).final, digits: 2)).replace("-", "−") Hz
    ],
  )

  let (xs-pass, ys-pass) = clean(run-pass.df)
  let (xs-fail, ys-fail) = clean(run-fail.df)
  let (xs-pass-loop, ys-pass-loop) = split(run-pass, false)
  let (xs-fail-loop, ys-fail-loop) = split(run-fail, false)
  let (xs-pass-chk, ys-pass-chk) = split(run-pass, true)
  let (xs-fail-chk, ys-fail-chk) = split(run-fail, true)
  let xmax = calc.max(run-pass.df.len(), run-fail.df.len()) - 1

  lq.diagram(
    width: 350mm * scale,
    height: 118mm * scale,
    xlabel: [$Delta f$ read],
    ylabel: [$Delta f$ (Hz)],
    xlim: (-1.5, xmax + 1.5),
    ylim: (-78, 4),
    legend: (position: top + left),

    lq.fill-between(
      (-4, xmax + 4),
      (band-lo, band-lo),
      y2: (band-shared, band-shared),
      fill: band-color.transparentize(80%),
      stroke: none,
      z-index: 0,
      label: [sharp bounds],
    ),
    lq.fill-between(
      (-4, xmax + 4),
      (band-shared, band-shared),
      y2: (band-hi, band-hi),
      fill: band-color.transparentize(90%),
      stroke: none,
      z-index: 0,
    ),

    lq.plot(xs-pass, ys-pass, stroke: trace-line(accent), mark: none),
    lq.plot(xs-fail, ys-fail, stroke: trace-line(fail-color), mark: none),

    lq.plot(
      xs-pass-loop, ys-pass-loop,
      stroke: none,
      mark: "o",
      mark-size: 5pt * scale,
      color: accent,
      label: [passed],
    ),
    lq.plot(
      xs-fail-loop, ys-fail-loop,
      stroke: none,
      mark: "o",
      mark-size: 5pt * scale,
      color: fail-color,
      label: [failed],
    ),

    lq.plot(
      xs-pass-chk + xs-fail-chk,
      ys-pass-chk + ys-fail-chk,
      stroke: none,
      mark: "d",
      mark-size: 7pt * scale,
      color: check-color,
      label: [stability reads],
    ),

    post-note(run-pass, 41, -7),
    post-note(run-fail, 32, -8),
  )
}
