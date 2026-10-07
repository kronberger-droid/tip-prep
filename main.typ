#import "lib.typ": run-figure
#import "runs.typ": runs

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
  align(horizon, run-figure(r.path, trim-front: r.trim-front, trim-back: r.trim-back))
  source-note(r)
  pagebreak(weak: true)
}
