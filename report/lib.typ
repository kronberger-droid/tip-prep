// Helper functions for data analysis, carried over from the labor-III reports.
// Add parsing routines for your own data format here.

#import calc: pow, sqrt

// An open question, missing source or unwritten part of the draft. Purple,
// since the figures use the blunt-red for their own states. Grep for `todo[`
// before handing the report in.
#let todo(body) = text(fill: rgb("8E24AA"), weight: "semibold")[[TODO: #body]]

#let mean(xs) = xs.sum() / xs.len()

// Sample standard deviation (Bessel-corrected).
#let stddev(xs) = {
  let m = mean(xs)
  sqrt(xs.map(x => pow(x - m, 2)).sum() / (xs.len() - 1))
}

// Standard error of the mean.
#let stderr(xs) = stddev(xs) / sqrt(xs.len())

// Unweighted least-squares fit of y = k*x + d.
// Returns a dictionary (slope, intercept).
#let linear-fit(xs, ys) = {
  let n = xs.len()
  let sum-x = xs.sum()
  let sum-y = ys.sum()
  let sum-xy = xs.zip(ys).map(p => p.at(0) * p.at(1)).sum()
  let sum-x2 = xs.map(x => x * x).sum()
  let slope = (n * sum-xy - sum-x * sum-y) / (n * sum-x2 - sum-x * sum-x)
  (
    slope: slope,
    intercept: (sum-y - slope * sum-x) / n,
  )
}

// --- Review notes ---------------------------------------------------------
//
// `#note[the text][the comment]` wraps the passage a comment is about, so in
// Helix it is select, surround, prefix `#note`, append `[comment]`. The passage
// gets a light highlight and a numbered marker in the left margin, neither of
// which moves any text. The comments are collected, with the passage quoted,
// on a page at the end (`review-page()`, placed last in `back-matter`). Each
// entry links back to the spot and shows its page and section.
//
// Compile with `--input review=off` to drop the highlight, the markers and the
// page, which leaves the passage as plain text.
#let review-on = sys.inputs.at("review", default: "on") != "off"
#let note-color = rgb("1E88E5")

// A fixed size, so it still lays out inside the zero-width box of `note`.
#let note-badge(n) = box(
  width: 1.6em,
  height: 1.1em,
  fill: note-color,
  radius: 2pt,
  align(center + horizon, text(size: 7pt, fill: white, weight: "bold", str(n))),
)

#let note(target, comment) = if not review-on { target } else {
  counter("review-note").step()
  [#metadata((target: target, comment: comment))<review-note>]
  context {
    let n = counter("review-note").get().first()
    // `here().position()` is page-absolute; shifting by -x lands the marker at
    // a fixed distance from the page edge, whatever the indent.
    let x = here().position().x
    // A zero-size inline box: a bare `place` is block-level and would split
    // the paragraph around it.
    box(width: 0pt, place(
      dx: 1.2cm - x,
      dy: -0.15em,
      link(label("review-entry-" + str(n)), note-badge(n)),
    ))
  }
  highlight(fill: note-color.transparentize(80%), target)
}

#let review-page() = if review-on {
  context {
    let notes = query(<review-note>)
    if notes.len() > 0 {
      pagebreak()
      heading(numbering: none, outlined: false)[Review notes]
      for (i, m) in notes.enumerate() {
        let loc = m.location()
        let page-no = counter(page).at(loc).first()
        let sections = query(selector(heading).before(loc)).filter(h => (
          h.level <= 2 and h.numbering != none
        ))
        let where-in = if sections.len() > 0 {
          let h = sections.last()
          [#numbering(h.numbering, ..counter(heading).at(h.location())) #h.body]
        }
        block(breakable: false, spacing: 1em, grid(
          columns: (1.8em, 1fr),
          column-gutter: 0.4em,
          [#note-badge(i + 1)#label("review-entry-" + str(i + 1))],
          [
            #text(size: 9pt, fill: luma(90))[#emph(m.value.target)]
            #linebreak()
            #m.value.comment
            #linebreak()
            #text(size: 9pt, fill: luma(90))[#link(loc)[p. #page-no]#if where-in != none [ · #where-in]]
          ],
        ))
      }
    }
  }
}
