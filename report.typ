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

#let report(
  // --- Inside the rules ---------------------------------------------------
  // `document-type` is the large bold line, `title` the smaller line below it.
  document-type: [Report],
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
    binding: left,
    margin: if margin != auto { margin } else if two-sided {
      (inside: 4cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    } else {
      (left: 3cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm)
    },
  )
  set text(lang: language, font: "New Computer Modern", size: 11pt)

  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level <= 2 {
      numbering("1.1", ..nums)
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
  show heading: it => {
    let numbered = it.level <= 2 and it.numbering != none
    if it.level == 1 {
      counter(math.equation).update(0)
    }
    block(
      above: if it.level == 1 { 3.5 * 4.7pt } else { 3.25 * 4.7pt },
      below: if it.level == 1 { 2.3 * 4.7pt } else { 1.5 * 4.7pt },
    )[
      #set text(size: if it.level == 1 { 14pt } else { 11pt }, weight: "bold")
      #if numbered [#context counter(heading).display(it.numbering)#h(0.5em)]
      #it.body
    ]
  }

  // \captionsetup{font=small, labelfont=bf, labelsep=period}
  set figure.caption(separator: [.#h(0.5em)])
  show figure.caption: it => block(width: 100%)[
    #set text(size: 10pt)
    #set par(justify: true, first-line-indent: 0pt)
    #set align(left)
    #text(weight: "bold")[
      #it.supplement #context it.counter.display(it.numbering)#it.separator
    ]#it.body
  ]

  // A bold name per line, as used for both the advisor and author lists.
  let name-list(names) = names.map(n => text(weight: "bold")[#n]).join(linebreak())

  let signature-lines = if signatures == auto {
    (
      if authors.len() > 0 { ((label: [Author:], name: authors.first()),) } else { () }
        + if supervisor != none { ((label: [Supervisor:], name: supervisor),) } else { () }
    )
  } else if signatures == none {
    ()
  } else {
    signatures
  }

  // A bare code block, not a `block()` element: set rules are scoped to it,
  // while the content still joins into the page flow so `v(1fr)` can expand.
  {
    // Every gap on this page is an explicit `v()`, so the automatic spacing
    // between paragraphs would otherwise be added on top of each one.
    set par(spacing: 0pt)

    if logo != none {
      image(width: logo-width, logo)
    }

    v(2cm)

    set align(center)

    line(length: 100%, stroke: rule-stroke)
    v(0.4cm)
    if document-type != none {
      text(size: 24pt, weight: "bold")[#document-type]
      v(0.5cm)
    }
    text(size: 14pt)[#title]
    v(0.4cm)
    line(length: 100%, stroke: rule-stroke)

    v(2cm)

    text(size: 17pt)[#smallcaps[#institution]]
    if faculty != none {
      v(0.5cm)
      text(size: 14pt)[#smallcaps[#faculty]]
    }
    if institute != none {
      v(0.5cm)
      text(size: 14pt)[#smallcaps[#institute]]
    }

    if advisors.len() > 0 {
      v(1cm)
      advisors-label
      v(0.3cm)
      name-list(advisors)
    }

    if authors.len() > 0 {
      v(0.5cm)
      authors-label
      v(0.3cm)
      name-list(authors)
      if matriculation != none {
        linebreak()
        matriculation
      }
    }

    if groupnumber != none {
      v(0.3cm)
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
          v(0.2cm)
          [#s.label \ #s.name]
        })
      )
      v(1cm)
    }

    text(size: 12pt)[
      #if type(date) == datetime {
        date.display(date-format)
      } else {
        date
      }
    ]
  }

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
    leading: 0.65em,
    spacing: 0.65em,
    first-line-indent: (amount: 17pt, all: false),
  )

  // Named `hd`, not `h`: the parameter would otherwise shadow the `h()`
  // spacing function used for the \quad between number and title.
  let show-mark(hd) = {
    let nums = counter(heading).at(hd.location())
    [#numbering("1.1", ..nums)#h(1em)#hd.body]
  }

  // fancyhdr's \leftmark: the left component of \botmark, so the last section
  // in effect at the foot of the page.
  let left-mark = context {
    let secs = query(heading.where(level: 1))
      .filter(h => h.location().page() <= here().page())
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
        stroke: (bottom: 0.4pt),
        inset: (bottom: 0.4em),
        // The zero-width strut keeps the rule at a fixed height on pages whose
        // mark is empty, such as a section opening before its first subsection.
        align(if even or not two-sided { left } else { right })[
          #box(width: 0pt, height: 1em)#if two-sided and not even { right-mark } else { left-mark }
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
}
