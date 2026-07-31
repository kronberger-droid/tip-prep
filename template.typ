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
//
// **A panel is a function of its own height, not finished content.** The call
// site is unchanged (`panel[Title][Body]`), but the result is a closure that
// `panel-column` invokes twice: once with `h: auto` to measure what the panel
// naturally holds, then with `h: 100%` to render it stretched to its row.
// A panel that hardcoded `height: 100%` could not be measured, since `measure`
// would hand it the whole region and get the region height straight back, which
// is the number we are trying to compute in the first place.
#let panel(title, body) = (h: 100%) => block(
  width: 100%,
  height: h,
  breakable: false,
  fill: panel-bg,
  stroke: 2pt + accent,
  radius: big-radius,
  clip: true,
  {
    block(
      width: 100%,
      fill: accent,
      // 0.55em, down from 0.8em. The bar is a label, not a band, and at 36pt
      // the glyphs already carry their own leading. Worth ~5 mm per panel, so
      // ~15 mm per column across three panels, which is more than any single
      // wording change has ever bought.
      inset: (x: 1em, y: 0.55em),
      text(size: 36pt, weight: "bold", fill: white, title),
    )
    // `above` is the lever, not the inset. The header bar and this block are two
    // consecutive *blocks*, so without it they inherit the poster's prose
    // paragraph spacing (`par.spacing`, 1.2em, ~11.8 mm at `base-size`) on top of
    // the inset. Measured, the bar-to-first-line gap was 16.9 mm of which only
    // ~4.9 mm was the inset. This takes it to ~6 mm, worth ~11 mm per panel.
    // Same mechanism that left the App screenshots floating below their intro.
    block(
      width: 100%,
      above: 0.4em,
      inset: (x: 0.5em, top: 0.3em, bottom: 0.5em),
      body,
    )
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

// A real figure: image plus a title, no frame. An STM scan already reads as a
// bounded object, so a box around it only adds a line to look at.
// Size by `height`, never by width: in a row of images, equal heights keep the
// titles on one baseline. Equal widths would not, since no two scans have
// exactly the same aspect ratio.
// `stack` rather than two blocks in sequence: consecutive `align()` calls are
// separate blocks and pick up the poster's paragraph spacing between them, which
// left a visible gulf between an image and its own title. `stack` spacing is
// explicit and tight.
//
// `caption-above` puts the title over the image instead of under it. The default
// is under, which is right when the caption is *data about the image* (the STM
// scans, whose captions are the acquisition parameters). Above is right when the
// caption *names* the thing, as in The App, where "live event stream" and "run
// parameters" tell you what you are about to look at: the eye reads the label
// first and then knows what it is looking for. Mixing the two on one poster is
// deliberate, not an oversight.
#let figure-img(path, caption, height: 90mm, caption-above: false) = {
  set par(justify: false)
  let img = align(center, image(path, height: height, fit: "contain"))
  let cap = align(center, text(size: 0.78em, weight: "bold", caption))
  stack(
    dir: ttb,
    spacing: 1em,
    ..if caption-above { (cap, img) } else { (img, cap) },
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

// One full-height column: a stack of panels that together fill the body height.
//
// **Row heights are measured, not typed.** Each panel is laid out once at its
// natural height to find out how much it actually holds, and the column's spare
// space is then handed out in proportion to that. A panel with twice the content
// gets twice the padding, which is what the hand-tuned `weights` were
// approximating: the old `(0.74, 1.55, 0.99)` is the ratio `194 : 406 : 242` in
// disguise. Nothing has to be retuned when a bullet is added or a figure resized.
//
// `weights` still overrides, for the cases where the honest proportional answer
// is not the wanted one. It skips the sizing, not the overfull check.
//
// **An overfull column is a hard error.** This is the point of the exercise.
// `panel` sets `clip: true`, so without the check the bottom of a panel is cut
// off in silence, and a `subbox` and a GUI screenshot have each been lost that
// way. Now it fails the build and says by how much. To fix one, cut content or
// shrink a figure; growing the weight only moves the overflow to a neighbour.
//
// `layout` gets the column's own width and height, which `measure` needs and
// which nothing else here knows. Cost is one extra layout pass over the poster's
// content, worth about 25% of the build.
#let panel-column(panels, weights: none) = layout(size => context {
  let n = panels.len()
  // `panel` yields a closure; anything else is taken as finished content and
  // measured as-is, so a plain block can still sit in a column.
  let at-height(p, h) = if type(p) == function { p(h: h) } else { p }

  let natural = panels.map(p => {
    measure(
      at-height(p, auto),
      width: size.width,
    ).height
  })
  let total = natural.fold(0pt, (a, b) => a + b)
  let avail = size.height - (n - 1) * col-gutter

  // 1pt of tolerance: `measure` and the real layout can disagree in the last
  // fraction of a point, and a build that fails by 0.3pt helps nobody.
  if total > avail + 1pt {
    panic(
      "panel column overfull by "
        + str(calc.round((total - avail).mm(), digits: 1))
        + " mm (content "
        + str(calc.round(total.mm(), digits: 1))
        + " mm, available "
        + str(calc.round(avail.mm(), digits: 1))
        + " mm). Cut content or shrink a figure in this column.",
    )
  }

  let rows = if weights == none {
    natural.map(h => (h / 1pt) * 1fr)
  } else {
    weights.map(w => w * 1fr)
  }

  block(
    width: 100%,
    height: 100%,
    grid(
      rows: rows,
      row-gutter: col-gutter,
      ..panels.map(p => at-height(p, 100%)),
    ),
  )
})

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
