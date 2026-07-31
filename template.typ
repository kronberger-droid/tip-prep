// Poster template: A0 portrait, header band, two panel columns, footer band.
// Everything sizes off `base-size` and `paper-size`. See CLAUDE.md.
#let accent = rgb("0267A5")
#let panel-bg = rgb("#ffffff")
#let band-bg = rgb("#e8ecf4")

#let paper-size = "a0"
#let page-margin = 22mm
#let col-gutter = 8mm
#let base-size = 28pt
#let big-radius = 20pt
#let small-radius = 4pt

#let logo(path, width: auto, height: auto) = image(
  path,
  width: width,
  height: height,
)

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
      inset: (x: 1em, y: 0.55em),
      text(size: 36pt, weight: "bold", fill: white, title),
    )
    block(
      width: 100%,
      above: 0.4em,
      inset: (x: 0.5em, top: 0.3em, bottom: 0.5em),
      body,
    )
  },
)

#let subbox(body) = block(
  width: 100%,
  fill: white,
  stroke: 0.5pt + gray,
  inset: 0.4em,
  radius: small-radius,
  body,
)

#let bib-refs(path, style: "ieee", cols: 3, full: false, gutter: 6mm) = {
  let bib = {
    set par(justify: false)
    show bibliography: set block(spacing: 0.3em)
    bibliography(path, title: none, style: style, full: full)
  }
  layout(size => {
    let colw = (size.width - (cols - 1) * gutter) / cols
    let h = measure(box(width: colw, bib)).height
    block(height: h / cols * 1.15, columns(cols, gutter: gutter, bib))
  })
}

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

#let figure-img(
  path,
  caption,
  height: 90mm,
  caption-above: false,
  stamp: none,
) = {
  set par(justify: false)
  let img = align(center, box({
    image(path, height: height, fit: "contain")
    if stamp != none {
      place(
        bottom + left,
        dx: 0.4em,
        dy: -0.4em,
        text(fill: white, size: 0.3em, stamp),
      )
    }
  }))
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
  logo-left: logo("assets/TU_Signet_RGB.svg", height: 75mm),
  logo-right: logo("assets/IAP_Signet_RGB.png", height: 75mm),
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
      block(above: 0.8em, width: 100%, grid(
        columns: (auto, 1fr, auto),
        column-gutter: 0.7em,
        align: horizon,
        logo-left,
        align(center)[
          #text(size: 1.6em, authors)
          #v(0.1em)
          #text(size: 1.2em, style: "italic", affiliations)
        ],
        logo-right,
      ))
    },
  )

  let contact-strip = if contact != none or url != none {
    block(
      width: 100%,
      text(size: 1em, fill: accent, grid(
        columns: (1fr, 1fr),
        align(left, contact), align(right, url),
      )),
    )
  } else { none }

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

  block(
    width: 100%,
    height: 100%,
    grid(
      rows: (auto, auto, 1fr, auto),
      row-gutter: (0.4em, col-gutter, col-gutter),
      header,
      contact-strip,
      body,
      footer,
    ),
  )
}

#let panel-column(panels, weights: none) = layout(size => context {
  let n = panels.len()
  let at-height(p, h) = if type(p) == function { p(h: h) } else { p }

  let natural = panels.map(p => {
    measure(
      at-height(p, auto),
      width: size.width,
    ).height
  })
  let total = natural.fold(0pt, (a, b) => a + b)
  let avail = size.height - (n - 1) * col-gutter

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
