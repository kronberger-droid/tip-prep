#import "@preview/lilaq:0.6.0" as lq
#import "lib.typ": run-figure
#import "runs.typ": runs

// Pick the frequency-shift axis with `--input yscale=linear|log`. "log" is
// symlog, since the shift is mostly negative and some runs cross zero; it is
// linear within ±1 Hz, which keeps the sharp window readable.
#let yscale = sys.inputs.at("yscale", default: "linear")
#let scales = (linear: "linear", log: lq.scale.symlog(threshold: 1.0))
#assert(yscale in scales, message: "yscale must be one of " + scales.keys().join(", ") + ", got " + yscale)

#let width = 12cm
#set page(width: width, height: width * 2 / 3, margin: 3mm)

// Identifies each page while the figures are being picked; drop it for export.
#let source-note(r) = {
  let trims = if r.trim-front != 0 or r.trim-back != 0 {
    "  (trim " + str(r.trim-front) + " / " + str(r.trim-back) + ")"
  }
  place(bottom + center, text(size: 6pt, fill: gray, raw(r.path.split("/").last() + trims)))
}

#for r in runs {
  align(horizon, run-figure(
    r.path,
    trim-front: r.trim-front,
    trim-back: r.trim-back,
    yscale: scales.at(yscale),
  ))
  source-note(r)
  pagebreak(weak: true)
}
