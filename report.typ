// Report template, generalized from the labor-III lab-report template.
//
// Applied from main.typ as:
//   #show: report.with(title: "...", authors: (...), ...)
//
// Every field on the title page is optional; a `none` field is simply omitted.

#let report(
  title: none,
  // The three smallcaps lines above the title rule. Set `course` to none to
  // drop the third line entirely.
  institution: [Vienna University of Technology],
  faculty: [Faculty of Physics],
  course: [Institute of Applied Physics],
  // The bold line inside the rules, above the title.
  document-type: [Report],
  authors: (),
  supervisor: none,
  groupnumber: none,
  date: datetime.today(),
  // Text of the running header on every page after the title. Defaults to the
  // title alone; pass e.g. [Tip Preparation - #title] for a course prefix.
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
  set align(center)

  image(width: 10cm, "assets/tuw_logo.jpg")

  v(3cm)

  text(size: 18pt)[#smallcaps[#institution]]
  v(0.2cm)
  text(size: 16pt)[#smallcaps[#faculty]]
  if course != none {
    v(0.2cm)
    text(size: 14pt)[#smallcaps[#course]]
  }

  v(2cm)
  line(length: 100%)
  text(size: 24pt, weight: "bold")[#document-type #v(0.2cm)]
  text(size: 18pt)[#title]
  line(length: 100%)
  v(1fr)

  grid(
    columns: (1fr, 1fr),
  )[
    #set align(left)
    #set text(size: 12pt)
    #text(weight: "bold")[
      #if authors.len() > 1 [Authors:] else [Author:] \
    ]
    #authors.join("\n")\
    #if groupnumber != none {
      text(weight: "bold")[Group #groupnumber]
    }
  ][
    #set align(right)
    #set text(size: 12pt)
    #if supervisor != none [
      #text(weight: "bold")[
        Supervisor:\
      ]
      #supervisor
    ]
  ]
  v(1cm)

  text[conducted on:\ ]
  date.display("[day] [month repr:long] [year]")

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
