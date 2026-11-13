// Report template. The title page follows the LaTeX front page from
// kronberger-droid/thesis-bachelor (`src/00_intro/title.tex`):
//
//   left-aligned logo, rules bracketing the document type and title, the
//   institution below them, then the advisor list, the submitting author, and
//   signature lines pushed to the foot of the page.
//
// Applied from main.typ as:
//   #show: report.with(title: [...], authors: (...), ...)
//
// Every text field takes either a string or content, so `[ ... ]` works
// everywhere. Every field is optional; passing `none` omits that block rather
// than leaving a gap.

// --- LaTeX metrics ---------------------------------------------------------
//
// The font sizes are the size/baselineskip pairs from `size11.clo`, the 11pt
// option of the article class. Note these are the round values: the 10.95 /
// 11.955 / 14.4 series belongs to the 10pt class, and using it makes every
// heading a little too large.
#import "/theme.typ" as th
#let sz = (
  footnotesize: 9pt,
  small: 10pt,
  normal: 11pt,
  large: 12pt,
  Large: 14pt,
  LARGE: 17pt,
  huge: 20pt,
  Huge: 25pt,
)
#let baselineskip = (
  footnotesize: 11pt,
  small: 12pt,
  normal: 13.6pt,
  large: 14pt,
)

// Typst spaces lines by `leading` *plus* the font's own line height, where
// LaTeX's \baselineskip is the whole baseline-to-baseline distance. This is
// the factor measured for New Computer Modern; it is font-specific.
#let line-height-factor = 0.682
#let leading-for(size, skip) = skip - line-height-factor * size

// LaTeX's \titlespacing is added on top of \baselineskip, where a Typst block
// gap replaces the paragraph spacing instead, so the article-class values
// (3.5ex/2.3ex around a section, 3.25ex/1.5ex around a subsection) do not
// transfer directly. These are the gaps that reproduce the baseline-to-
// baseline distances measured in the thesis PDF: 26.2pt below a section, and
// 28.8pt / 20.6pt around a subsection. The space above a section is derived
// rather than measured, since every section in the thesis opens a page.
#let heading-space = (
  section: (above: 23.5pt, below: 17.9pt),
  subsection: (above: 21.3pt, below: 13.1pt),
)

// The stylesheet of the HTML export, in the colours of theme.typ, so
// `--input theme=dark` gives a dark page as it gives a dark PDF. It styles
// the title header below and the `.fragment` blocks of the code listings.
#let html-style() = {
  let c(x) = x.to-hex()
  html.elem("style", "
    :root { color-scheme: " + if th.dark { "dark" } else { "light" } + "; }
    body { background: " + c(th.paper) + "; color: " + c(th.ink) + ";
      font-family: 'New Computer Modern', 'Latin Modern Roman', Georgia, serif;
      font-size: 1.05rem; line-height: 1.5; max-width: 46rem; margin: 2rem auto; padding: 0 1.2rem; }
    h2 { margin-top: 2.6rem; border-bottom: 1px solid " + c(th.grey(200)) + "; padding-bottom: .2rem; }
    h3, h4 { margin-top: 1.8rem; }
    a { color: " + c(th.accent) + "; text-decoration: none; } a:hover { text-decoration: underline; }
    figure { margin: 1.8rem 0; text-align: center; overflow-x: auto; }
    figure svg, figure img { max-width: 100%; height: auto; }
    figcaption { font-size: .88rem; text-align: left; margin-top: .6rem; color: " + c(th.grey(60)) + "; }
    table { border-collapse: collapse; margin: 0 auto; font-size: .88rem; text-align: left; }
    td, th { border: 1px solid " + c(th.grey(150)) + "; padding: .25rem .55rem; vertical-align: top; }
    code { font-family: 'DejaVu Sans Mono', ui-monospace, monospace; font-size: .86em; }
    pre { text-align: left; overflow-x: auto; margin: .2rem 0 0; font-size: .8rem; line-height: 1.35; }
    .fragment { border: 1px solid " + c(th.grey(160)) + "; padding: .5rem .7rem; margin: .4rem 0; text-align: left; }
    .fragment-head { font-size: .78rem; color: " + c(th.grey(90)) + "; }
    nav ol, nav ul { list-style: none; padding-left: 1.2rem; }
    header.title { text-align: center; margin: 1rem 0 3rem; padding-bottom: 1.6rem; border-bottom: 2px solid " + c(th.ink) + "; }
    header.title img { display: block; width: 15rem; max-width: 60%; height: auto; margin: 0 0 2.5rem; border-radius: 3px; }
    header.title .name, header.title .matr { display: inline-block; }
    header.title .name + .name::before { content: ', '; white-space: pre; }
    header.title .matr { margin-left: .4em; }
    header.title .matr::before { content: '('; } header.title .matr::after { content: ')'; }
    header.title .doctype { font-size: 1.1rem; letter-spacing: .08em; text-transform: uppercase; margin: 0; color: " + c(th.grey(90)) + "; }
    header.title h1 { font-size: 2.1rem; line-height: 1.2; margin: .5rem 0 1rem; }
    header.title .institution { font-variant: small-caps; font-size: 1.15rem; margin: 0 0 1.6rem; }
    header.title .people { margin: .25rem 0; }
    header.title .label { color: " + c(th.grey(90)) + "; margin-right: .6em; }
    header.title .label::after { content: ':'; }
    header.title .date { margin: 1.4rem 0 0; color: " + c(th.grey(90)) + "; }
  ")
}

#let report(
  // --- Inside the rules ---------------------------------------------------
  // `document-type` is the large bold line, `title` the smaller line below it.
  document-type: [Project Work],
  title: none,
  // --- Below the rules ----------------------------------------------------
  institution: [Vienna University of Technology],
  faculty: none,
  institute: [Institute of Applied Physics],
  // --- Attribution --------------------------------------------------------
  // Names listed under `advisors-label`, in bold, one per line.
  advisors: (),
  advisors-label: [under guidance of],
  // Names listed under `authors-label`, in bold, one per line, with
  // `matriculation` as a plain line underneath.
  authors: (),
  authors-label: [submitted by],
  matriculation: none,
  groupnumber: none,
  // Used for the signature line only; `advisors` is the printed list above.
  supervisor: none,
  // --- Signature lines at the foot ----------------------------------------
  // `auto` derives (Author: first author) and (Supervisor: supervisor).
  // `none` omits the block. Otherwise an array of (label: .., name: ..).
  signatures: auto,
  signature-width: 6cm,
  // --- Misc ---------------------------------------------------------------
  // A datetime is formatted with `date-format`; anything else is shown as-is,
  // so `date: [Summer term 2026]` is also valid.
  date: datetime.today(),
  date-format: "[day] [month repr:long] [year]",
  logo: "assets/tuw_logo.jpg",
  logo-width: 80%,
  rule-stroke: 0.5mm,
  // --- Document structure -------------------------------------------------
  // Everything between the title page and the table of contents: declaration,
  // acknowledgements, abstract. Counted but unnumbered and without a header,
  // the way \pagenumbering{roman} with \pagestyle{empty} leaves it.
  front-matter: none,
  outline-contents: true,
  outline-title: [Contents],
  outline-depth: 3,
  // Placed after the body with sections renumbered A, B, C, as \appendix does.
  appendix: none,
  // Placed last, for the bibliography and any lists of figures or tables.
  back-matter: none,
  // Two-sided printing: alternating margins, the section name in the header of
  // even pages and the subsection name on odd ones, page number in the outer
  // corner. Set false for a single-sided report.
  two-sided: true,
  // `auto` uses the thesis geometry; otherwise any `page.margin` value.
  margin: auto,
  language: "en",
  doc,
) = {
  // `geometry` in the LaTeX preamble: inner 3cm plus a 1cm binding offset,
  // outer 2.5cm, 2.5cm top and bottom. `inside`/`outside` alternate by page
  // parity, so they are only right for a two-sided document.
  set page(
    paper: "a4",
    fill: if th.dark { th.paper } else { auto },
    binding: left,
    margin: if margin != auto { margin } else if two-sided {
      (inside: 4cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    } else {
      (left: 3cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    },
  )
  set text(lang: language, font: "New Computer Modern", size: sz.normal, fill: th.ink)
  // Rules and frames take the ink too: a stroke given as a bare thickness
  // folds into these, where it would otherwise be black.
  set line(stroke: th.ink)
  set table(stroke: th.ink)
  set raw(theme: th.raw-theme) if th.dark

  // \secnumdepth is 3 in the article class, so subsubsections are numbered too.
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level <= 3 {
      numbering("1.1.1", ..nums)
    }
  })

  // \numberwithin{equation}{section}: (2.1), (2.2), restarting each section.
  set math.equation(numbering: n => {
    let sec = counter(heading).get()
    numbering("(1.1)", if sec.len() > 0 { sec.first() } else { 0 }, n)
  })

  // \titleformat: \large\bfseries for sections, \normalsize\bfseries for
  // subsections, number and title separated by 0.5em. Spacing is the article
  // class default that titlesec leaves alone, in ex at 11pt.
  show heading: it => context {
    // HTML has headings of its own; the print styling below is for paper.
    if target() == "html" { return it }
    let numbered = it.level <= 3 and it.numbering != none
    if it.level == 1 {
      counter(math.equation).update(0)
    }
    let size = if it.level == 1 { sz.large } else { sz.normal }
    let skip = if it.level == 1 { baselineskip.large } else {
      baselineskip.normal
    }
    let space = if it.level == 1 { heading-space.section } else {
      heading-space.subsection
    }
    block(above: space.above, below: space.below)[
      #set text(size: size, weight: "bold")
      #set par(leading: leading-for(size, skip))
      #if numbered [#context counter(heading).display(it.numbering)#h(0.5em)]
      #it.body
    ]
  }

  // \l@section and \@dottedtocline{level}{indent}{numwidth}: the article class
  // uses {0em}{1.5em} for sections, {1.5em}{2.3em} for subsections and
  // {3.8em}{3.2em} below that. The number sits in a fixed column so the titles
  // line up, and the page number is right-aligned in a \@pnumwidth box, which
  // is what leaves the gap between the leaders and the number. Sections are
  // bold and take \hfil instead of dot leaders.
  let pnumwidth = 1.55em
  // One block per entry, or consecutive entries join into a single paragraph
  // and wrap into each other. The indent is the entry's own, so the body's
  // \parindent has to be switched off here.
  let toc-entry(it, indent, numwidth, dots: true, prefix: auto) = context if target() == "html" {
    // No leaders or page numbers in HTML: the number, a space and the title.
    let p = if prefix == auto { it.prefix() } else { prefix }
    link(it.element.location())[#if p != none [#p~]#it.body()]
  } else { block(
    width: 100%,
    spacing: leading-for(sz.normal, baselineskip.normal),
    {
      set par(first-line-indent: 0pt)
      link(it.element.location(), {
        h(indent)
        // Unnumbered entries reserve no column, so a \section* sits flush left.
        let prefix = if prefix == auto { it.prefix() } else { prefix }
        if prefix != none {
          box(width: numwidth)[#prefix]
        }
        it.body()
        if dots {
          // \@dotsep is 4.5mu either side of the dot, so 0.5em between them,
          // which measures as an 8.5pt pitch at 11pt.
          box(width: 1fr, inset: (x: 0.4em), repeat[.#h(0.5em)])
        } else {
          h(1fr)
        }
        box(width: pnumwidth, align(right, it.page()))
      })
    },
  ) }

  show outline.entry.where(level: 1): it => {
    if it.element.func() == figure {
      // \l@figure is \@dottedtocline{1}{1.5em}{2.3em}: the bare number in its
      // column, dot leaders, regular weight, and no extra space above.
      let fig = it.element
      let number = numbering(fig.numbering, ..fig.counter.at(fig.location()))
      return toc-entry(it, 1.5em, 2.3em, prefix: number)
    }
    // \addvspace{1.0em}, on top of the line spacing rather than replacing it.
    v(1em)
    strong(toc-entry(it, 0em, 1.5em, dots: false))
  }
  show outline.entry.where(level: 2): it => toc-entry(it, 1.5em, 2.3em)
  show outline.entry.where(level: 3): it => toc-entry(it, 3.8em, 3.2em)

  // \intextsep: room between a figure and the text around it.
  show figure: set block(above: 1.5em, below: 1.5em)

  // Tables: hairlines instead of Typst's 1pt default, \footnotesize text, and the
  // header row in bold. Only for table figures, since a diagram may be drawn
  // with `table` too; every table figure here opens with a `table.header`.
  show figure.where(kind: table): set table(stroke: 0.4pt)
  show figure.where(kind: table): set text(size: sz.footnotesize)
  show figure.where(kind: table): it => {
    show table.cell.where(y: 0): set text(weight: "bold")
    it
  }

  // The reference list one step below the body, as \small.
  show bibliography: set text(size: sz.small)

  // \captionsetup{font=footnotesize, labelfont=bf, labelsep=period}
  // A plain space in HTML, where `h` has no meaning.
  set figure.caption(separator: context if target() == "html" [. ] else [.#h(0.5em)])
  show figure.caption: it => context if target() == "html" { it } else { block(width: 100%)[
    #set text(size: sz.footnotesize)
    #set par(
      justify: true,
      first-line-indent: 0pt,
      leading: leading-for(sz.footnotesize, baselineskip.footnotesize),
    )
    #set align(left)
    #text(weight: "bold")[
      #it.supplement #context it.counter.display(it.numbering)#it.separator
    ]#it.body
  ] }

  // A bold name per line, as used for both the advisor and author lists.
  let name-list(names) = names
    .map(n => text(weight: "bold")[#n])
    .join(linebreak())

  let signature-lines = if signatures == auto {
    (
      if authors.len() > 0 {
        ((label: [Author:], name: authors.first()),)
      } else { () }
        + if supervisor != none {
          ((label: [Supervisor:], name: supervisor),)
        } else { () }
    )
  } else if signatures == none {
    ()
  } else {
    signatures
  }

  // A bare code block, not a `block()` element: set rules are scoped to it,
  // while the content still joins into the page flow so `v(1fr)` can expand.
  let print-title = {
    // Every gap on this page is an explicit `v()`, so the automatic spacing
    // between paragraphs would otherwise be added on top of each one.
    set par(spacing: 0pt, leading: leading-for(sz.normal, baselineskip.normal))

    // The title page is one \\-separated paragraph in the LaTeX, so each
    // \\[x] puts x *on top of* \baselineskip. A Typst `v(x)` is the whole gap,
    // so the leading has to be added back. Between lines of different sizes
    // TeX falls back to \lineskip and the extra comes out smaller, so those
    // gaps are measured against the thesis title page rather than derived.
    let gap = leading-for(sz.normal, baselineskip.normal)

    if logo != none {
      image(width: logo-width, logo)
    }

    // \vspace{2cm}, plus the \topsep the `center` environment opens with and
    // the line box the \HRule sits in. Measured: the thesis rule is at 247.5pt.
    v(2cm + 24.5pt)

    set align(center)

    line(length: 100%, stroke: rule-stroke)
    v(0.4cm + 2.3pt)
    if document-type != none {
      text(size: sz.Huge, weight: "bold")[#document-type]
      v(0.5cm + 3.5pt)
    }
    text(size: sz.Large)[
      // `{\Large ..}\\` closes the group before \par, so the two title lines
      // are set on the 11pt \baselineskip rather than \Large's 18pt.
      #set par(leading: baselineskip.normal - line-height-factor * sz.Large)
      #title
    ]
    v(0.4cm + 1.7pt)
    line(length: 100%, stroke: rule-stroke)

    v(2cm + 2.5pt)

    text(size: sz.LARGE)[#smallcaps[#institution]]
    if faculty != none {
      v(0.5cm + 4pt)
      text(size: sz.Large)[#smallcaps[#faculty]]
    }
    if institute != none {
      v(0.5cm + 4pt)
      text(size: sz.Large)[#smallcaps[#institute]]
    }

    if advisors.len() > 0 {
      v(1cm + 6.3pt)
      advisors-label
      v(0.3cm + gap)
      name-list(advisors)
    }

    if authors.len() > 0 {
      v(0.5cm + gap)
      authors-label
      v(0.3cm + gap)
      name-list(authors)
      if matriculation != none {
        linebreak()
        matriculation
      }
    }

    if groupnumber != none {
      v(0.3cm + gap)
      text(weight: "bold")[Group #groupnumber]
    }

    v(1fr)

    // Fixed-width cells with expanding gutters, so the first sits flush left
    // and the last flush right however many there are.
    if signature-lines.len() > 0 {
      grid(
        columns: (signature-width,) * signature-lines.len(),
        column-gutter: 1fr,
        ..signature-lines.map(s => {
          set align(left)
          line(length: 100%, stroke: 0.4pt)
          v(0.2cm + gap)
          [#s.label \ #s.name]
        })
      )
      v(1cm + 3.1pt)
    }

    text(size: sz.large)[
      #if type(date) == datetime {
        date.display(date-format)
      } else {
        date
      }
    ]
    // The \topsep that closes the `center` environment. Fixed space rather
    // than trailing padding: the `v(1fr)` above shrinks by it, so the whole
    // signature-and-date group rises instead of the space being dropped.
    v(12pt)
  }

  // The same facts as a page header for the HTML export, where the spacing
  // and rules of the printed title page mean nothing. Styled by the
  // stylesheet in lib.typ (`header.title`).
  let html-title() = {
    let line-of(label, names) = html.elem("div", attrs: (class: "people"), {
      html.elem("span", attrs: (class: "label"), label)
      names.map(n => html.elem("span", attrs: (class: "name"), n)).join()
    })
    html-style()
    html.elem("header", attrs: (class: "title"), {
      if logo != none { image(logo) }
      if document-type != none {
        html.elem("p", attrs: (class: "doctype"), document-type)
      }
      html.elem("h1", title)
      html.elem("p", attrs: (class: "institution"), {
        (institution, faculty, institute).filter(x => x != none).join[ · ]
      })
      if authors.len() > 0 {
        line-of(authors-label, authors.map(a => {
          a
          if matriculation != none { html.elem("span", attrs: (class: "matr"), matriculation) }
        }))
      }
      if advisors.len() > 0 { line-of(advisors-label, advisors) }
      html.elem("p", attrs: (class: "date"), if type(date) == datetime {
        date.display(date-format)
      } else { date })
    })
  }

  context if target() == "html" { html-title() } else { print-title }

  // The thesis puts a \blankpage verso after the title page, which is also
  // what keeps the printed page numbers in step with the physical ones: Typst
  // alternates the inside/outside margins by physical page, while the header
  // and footer follow the counter. Starting the body on a physical odd page
  // makes the two agree.
  if two-sided { pagebreak(to: "odd") } else { pagebreak() }

  set align(left)
  // \parskip is 0 in the article class, so paragraphs run on with only the
  // first line indented by \parindent (17pt at 11pt). Matching `spacing` to
  // `leading` is what removes the gap Typst would otherwise insert.
  set par(
    justify: true,
    leading: leading-for(sz.normal, baselineskip.normal),
    spacing: leading-for(sz.normal, baselineskip.normal),
    first-line-indent: (amount: 17pt, all: false),
  )

  // Named `hd`, not `h`: the parameter would otherwise shadow the `h()`
  // spacing function used for the \quad between number and title.
  let show-mark(hd) = {
    // The heading's own numbering, not a hardcoded "1.1": in the appendix the
    // same mark has to come out as A, B, C.
    if hd.numbering == none {
      hd.body
    } else {
      let nums = counter(heading).at(hd.location())
      [#numbering(hd.numbering, ..nums)#h(1em)#hd.body]
    }
  }

  // fancyhdr's \leftmark: the left component of \botmark, so the last section
  // in effect at the foot of the page.
  let left-mark = context {
    let secs = query(heading.where(level: 1)).filter(h => (
      h.location().page() <= here().page()
    ))
    if secs.len() > 0 { show-mark(secs.last()) }
  }

  // fancyhdr's \rightmark: the right component of \firstmark, so whichever
  // mark the first heading on the page left behind. \subsectionmark sets it;
  // \sectionmark clears it, via \markboth{..}{} in the article class. With no
  // heading on the page at all, the mark carries over from the one before.
  let right-mark = context {
    let page-now = here().page()
    let marks = query(heading).filter(h => h.level <= 2)
    let on-page = marks.filter(h => h.location().page() == page-now)
    let carried = marks.filter(h => h.location().page() < page-now)
    let first-mark = if on-page.len() > 0 {
      on-page.first()
    } else if carried.len() > 0 {
      carried.last()
    }
    if first-mark != none and first-mark.level == 2 { show-mark(first-mark) }
  }

  // \pagenumbering{roman} \pagestyle{empty}: the front matter is counted but
  // shows neither header nor page number, so nothing needs displaying here.
  if front-matter != none {
    front-matter
    if two-sided { pagebreak(to: "odd") } else { pagebreak() }
  }

  if outline-contents {
    outline(title: outline-title, depth: outline-depth)
    if two-sided { pagebreak(to: "odd") } else { pagebreak() }
  }

  // \pagenumbering{arabic} \pagestyle{fancy}
  counter(page).update(1)
  set page(
    // [LE]{\leftmark}: the section, on the left of even pages.
    // [RO]{\rightmark}: the subsection, on the right of odd ones.
    header: context {
      // Parity follows the printed page number, which the reset after the
      // title page puts out of step with the physical page index.
      let even = two-sided and calc.even(counter(page).get().first())
      block(
        width: 100%,
        stroke: (bottom: 0.4pt + th.ink),
        inset: (bottom: 0.4em),
        // The zero-width strut keeps the rule at a fixed height on pages whose
        // mark is empty, such as a section opening before its first subsection.
        align(if even or not two-sided { left } else { right })[
          #box(width: 0pt, height: 1em)#if two-sided and not even {
            right-mark
          } else { left-mark }
        ],
      )
    },
    // \fancyfoot[LE,RO]{\thepage}: the outer bottom corner.
    footer: context {
      // Parity follows the printed page number, which the reset after the
      // title page puts out of step with the physical page index.
      let even = two-sided and calc.even(counter(page).get().first())
      align(if even { left } else { right })[#counter(page).display("1")]
    },
  )

  doc

  // \appendix: sections renumbered A, B, C, with the counter restarted.
  if appendix != none {
    if two-sided { pagebreak(to: "odd") } else { pagebreak() }
    counter(heading).update(0)
    set heading(numbering: (..nums) => {
      let level = nums.pos().len()
      if level == 1 {
        numbering("A", ..nums)
      } else if level <= 3 {
        numbering("A.1.1", ..nums)
      }
    })
    appendix
  }

  if back-matter != none {
    if two-sided { pagebreak(to: "odd") } else { pagebreak() }
    back-matter
  }
}

// --- Helpers for the document body -----------------------------------------

// \section*{..}: a heading with no number. Outlined, and so the equivalent of
// following it with \addcontentsline{toc}{section}{..}; pass `outlined: false`
// for the ones the thesis leaves out of the table of contents.
#let unnumbered(title, level: 1, outlined: true) = heading(
  level: level,
  numbering: none,
  outlined: outlined,
)[#title]

// \blankpage: a page with nothing on it, not even a header or page number.
#let blank-page() = page(header: none, footer: none)[]

// The declaration page from `src/00_intro/declaration.tex`: a centred \LARGE
// bold title, the author in bold, the declaration itself, and a signature rule
// pushed to the foot. The text is a parameter, since it is yours to word.
#let declaration(
  title: [Declaration of Authorship],
  author: none,
  place: none,
  date: datetime.today(),
  date-format: "[day] [month repr:long] [year]",
  signature-width: 6cm,
  body,
) = {
  // Nothing on this page is running prose, so nothing is indented.
  set par(first-line-indent: 0pt)

  // \vspace*{1cm}, plus the offset \topskip puts before the first line of a
  // page. Measured against the thesis PDF, which puts the title top at 121.8pt.
  v(1cm + 24.6pt)
  // A real heading in HTML, kept out of the contents as on paper.
  context if target() == "html" {
    heading(level: 1, numbering: none, outlined: false)[#title]
  } else {
    align(center, text(size: sz.LARGE, weight: "bold")[#title])
  }
  v(2cm)

  if author != none {
    text(weight: "bold")[#author]
    v(0.5cm + leading-for(sz.normal, baselineskip.normal))
  }

  // Scoped, so the wider paragraph spacing does not also land between the
  // title and the author above.
  {
    // \\[0.3cm] between the two statements. As with the headings, a LaTeX skip
    // is added to \baselineskip where a Typst gap replaces the leading.
    set par(spacing: leading-for(sz.normal, baselineskip.normal) + 0.3cm)
    body
  }

  v(1fr)

  block(width: signature-width)[
    #line(length: 100%, stroke: 0.5pt)
    #author \
    #{
      if place != none [#place, ]
      if type(date) == datetime { date.display(date-format) } else { date }
    }
  ]
  v(1fr)
}

// \listoffigures and \listoftables.
// \caption[short]{long}: the figure shows `long`, the lists show `short`.
#let in-outline = state("in-outline", false)
#let flex-caption(long, short) = context if in-outline.get() { short } else {
  long
}

#let list-of-figures(title: [List of Figures]) = {
  in-outline.update(true)
  outline(title: title, target: figure.where(kind: image))
  in-outline.update(false)
}
#let list-of-tables(title: [List of Tables]) = {
  in-outline.update(true)
  outline(title: title, target: figure.where(kind: table))
  in-outline.update(false)
}
