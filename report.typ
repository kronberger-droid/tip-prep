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
  // Text of the running header on every page after the title. Defaults to the
  // title alone; pass e.g. [Tip Preparation - #title] for a section prefix.
  running-header: auto,
  language: "en",
  doc,
) = {
  set page(paper: "a4")
  set text(lang: language, font: "New Computer Modern", size: 11pt)

  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level <= 2 {
      numbering("1.1", ..nums)
    }
  })

  set math.equation(numbering: "(1)")

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

  pagebreak()

  set align(left)
  set par(justify: true)

  counter(page).update(1)
  set page(
    numbering: "1",
    header: [
      #set align(center)
      #if running-header == auto { title } else { running-header }
    ],
  )

  doc
}
