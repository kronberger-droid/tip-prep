// Poster template: A0 portrait, header band + panel grid + footer band.
// Styling is deliberately plain — tweak the constants below first.

#let accent = rgb("0267A5")
#let panel-bg = rgb("#ffffff")
#let band-bg = rgb("#e8ecf4")

// Page geometry. `paper` takes any ISO name, so "a1" or "a2" also work and
// nothing below needs touching — sizes are all relative.
#let paper-size = "a0"
#let page-margin = 22mm
#let col-gutter = 8mm
// Base font size. Every other size is expressed in `em`, so changing this
// one number rescales the whole poster.
#let base-size = 28pt
#let big-radius = 20pt
#let small-radius = 4pt

// Placeholder for a logo that does not exist yet.
// Swap calls to this for `image("images/tuwien.svg", width: ...)` later.
#let logo(path, width: auto, height: auto) = image(
  path,
  width: width,
  height: height,
)

// A titled content panel: colored header bar + body area.
// The fill lives on the outer block so the grey reaches the bottom of the
// stretched row, not just the bottom of the text.
#let panel(title, body) = block(
  width: 100%,
  height: 100%,
  breakable: false,
  fill: panel-bg,
  stroke: 2pt + accent,
  radius: big-radius,
  clip: true,
  {
    block(
      width: 100%,
      fill: accent,
      inset: (x: 1em, y: 1em),
      text(size: 40pt, weight: "bold", fill: white, title),
    )
    block(width: 100%, inset: 0.5em, body)
  },
)

// A light sub-box inside a panel, for figures/notes.
#let subbox(body) = block(
  width: 100%,
  fill: white,
  stroke: 0.5pt + gray,
  inset: 0.4em,
  radius: small-radius,
  body,
)

// References rendered from a real .bib file, for the `references:` argument
// of `poster`. Only entries you actually cite with `@key` are listed; pass
// `full: true` to list the whole file. Text size comes from the footer band,
// so this deliberately does not set it.
// `columns()` alone fills column 1 top-to-bottom and only spills over when it
// runs out of vertical room — in the auto-height footer that never happens, so
// every entry stacks in the first column. To spread them horizontally we
// measure the single-column height, then cap the block at ~1/cols of it so the
// entries are forced to flow across all columns (balanced).
#let bib-refs(path, style: "ieee", cols: 3, full: false, gutter: 6mm) = {
  let bib = {
    set par(justify: false)
    show bibliography: set block(spacing: 0.3em)
    bibliography(path, title: none, style: style, full: full)
  }
  layout(size => {
    let colw = (size.width - (cols - 1) * gutter) / cols
    let h = measure(box(width: colw, bib)).height
    // 1.15 gives each column ~1/cols of the height plus a little slack, so the
    // greedy column fill lands ~evenly instead of dumping the remainder into
    // the last column. Nudge up if a future entry overflows the last column.
    block(height: h / cols * 1.15, columns(cols, gutter: gutter, bib))
  })
}

// Stand-in for a figure you have not made yet. The dashed rule is the only
// border here: a `subbox` around it would double-box the placeholder.
//
// `width` and `caption` exist so a stub can stand in a row beside real
// `figure-img` figures without breaking it: pass the same `height` both take,
// a `width` matching the real images' aspect, and the caption then sits
// underneath on the same baseline as theirs.
#let figure-stub(label, height: 90mm, width: 100%, caption: none) = {
  set par(justify: false)
  let frame = rect(
    width: width,
    height: height,
    stroke: (dash: "dashed", paint: gray),
    align(center + horizon, text(fill: gray, label)),
  )
  if caption == none {
    align(center, frame)
  } else {
    stack(
      dir: ttb,
      spacing: 0.35em,
      align(center, frame),
      align(center, text(size: 0.78em, weight: "bold", caption)),
    )
  }
}

// A real figure: title above, image below, no frame. An STM scan already reads
// as a bounded object, so a box around it only adds a line to look at.
// Size by `height`, never by width: in a row of images, equal heights keep the
// titles on one baseline. Equal widths would not, since no two scans have
// exactly the same aspect ratio.
// Title goes *underneath* the image. `stack` rather than two blocks in sequence:
// consecutive `align()` calls are separate blocks and pick up the poster's
// paragraph spacing between them, which left a visible gulf between an image and
// its own title. `stack` spacing is explicit and tight.
#let figure-img(path, caption, height: 90mm) = {
  set par(justify: false)
  stack(
    dir: ttb,
    spacing: 0.35em,
    align(center, image(path, height: height, fit: "contain")),
    align(center, text(size: 0.78em, weight: "bold", caption)),
  )
}

#let poster(
  title: [],
  subtitle: none,
  authors: [],
  affiliations: [],
  contact: none,
  url: none,
  logo-left: logo("assets/TU_Signet_RGB.svg", height: 80mm),
  logo-right: logo("assets/IAP_Signet_RGB.png", height: 80mm),
  footer-logos: (),
  references: none,
  body,
) = {
  set page(
    paper: paper-size,
    flipped: false,
    margin: page-margin,
    fill: white,
  )
  set text(font: "Libertinus Serif", size: base-size, lang: "en")
  set par(justify: true, leading: 0.65em)

  show heading.where(level: 2): set text(size: 1.1em, fill: accent)
  show heading.where(level: 3): set text(size: 1em, fill: accent)

  // ---- header band ----
  let header = block(
    width: 100%,
    fill: band-bg,
    stroke: 1pt + accent,
    inset: (x: 0.6em, top: 0.9em, bottom: 0.6em),
    radius: big-radius,
    {
      align(center)[
        #text(size: 2.8em, weight: "bold", fill: accent, title)
        #if subtitle != none [\ #text(size: 1.8em, fill: accent, subtitle) ]
      ]
      grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.7em,
        align: horizon,
        logo-left,
        align(center)[
          #text(size: 1.35em, authors)
          #v(0.2em)
          #text(size: 1.2em, style: "italic", affiliations)
        ],
        logo-right,
      )
    },
  )

  // ---- contact strip ----
  let contact-strip = if contact != none or url != none {
    block(
      width: 100%,
      text(size: 1em, fill: accent, grid(
        columns: (1fr, 1fr),
        align(left, contact), align(right, url),
      )),
    )
  } else { none }

  // ---- footer band ----
  let footer = block(
    width: 100%,
    fill: band-bg,
    stroke: 1pt + accent,
    inset: 0.6em,
    radius: 2pt,
    {
      if footer-logos.len() > 0 {
        grid(
          columns: (1fr,) * footer-logos.len(),
          align: horizon + center,
          ..footer-logos,
          v(0.4em),
          line(length: 100%, stroke: 0.5pt + gray),
        )
      }
      if references != none {
        v(0.3em)
        text(size: 0.65em, references)
      }
    },
  )

  // ---- page assembly ----
  // A full-page-height block gives the grid a known region, so the `1fr`
  // body row soaks up whatever the header and footer leave over.
  block(
    width: 100%,
    height: 100%,
    grid(
      rows: (auto, auto, 1fr, auto),
      // Per-gap: contact strip hugs the header, then the body is separated
      // from both contact and footer by the same gutter used between panels.
      row-gutter: (0.4em, col-gutter, col-gutter),
      header,
      contact-strip,
      body,
      footer,
    ),
  )
}

// One full-height column: a stack of panels that together fill the body
// height. By default every panel gets an equal share; pass `weights` (one
// number per panel) to make some taller, e.g. weights: (2, 3) gives the
// second panel 3/5 of the height.
#let panel-column(panels, weights: none) = {
  let n = panels.len()
  let rows = if weights == none {
    (1fr,) * n
  } else {
    weights.map(w => w * 1fr)
  }
  block(
    width: 100%,
    height: 100%,
    grid(rows: rows, row-gutter: col-gutter, ..panels),
  )
}

// Two side-by-side columns whose heights are computed independently. Each
// column is its own full-height grid, so the left column's row splits have
// no effect on the right column's, and vice versa. `left`/`right` are arrays
// of panels; `weights-left`/`weights-right` optionally weight them.
#let panel-columns(
  left,
  right,
  weights-left: none,
  weights-right: none,
) = block(
  width: 100%,
  height: 100%,
  grid(
    columns: (1fr, 1fr),
    column-gutter: col-gutter,
    panel-column(left, weights: weights-left),
    panel-column(right, weights: weights-right),
  ),
)
