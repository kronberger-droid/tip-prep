#import "report.typ": report, blank-page, list-of-figures, list-of-tables
#import "lib.typ": *
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/unify:0.8.1": num, qty

#show: report.with(
  title: [ Automated, Reproducible Conditioning of SPM Tips ],
  advisors: (
    [ Ing. Adam Lagin ],
    [ Dr.techn. Jiri Pavelec ],
  ),
  authors: ([ Martin Kronberger ],),
  matriculation: [ Matr.-Nr.: 12202316 ],
  supervisor: [ Dr.techn. Jiri Pavelec ],
  date: datetime.today(),

  // Each piece is followed by a blank verso, the way every front-matter file
  // in the thesis ends with \blankpage, so each one opens on a recto.
  front-matter: [
    #include "src/00_intro/declaration.typ"
    #blank-page()
    #include "src/00_intro/acknowledgements.typ"
    #blank-page()
    #include "src/00_intro/abstract.typ"
    #blank-page()
  ],

  appendix: [
    #include "src/A_appendix/default.typ"
  ],

  back-matter: [
    #list-of-figures()
    #list-of-tables()
    #pagebreak()
    #bibliography(
      "src/B_bibliography/references.bib",
      title: [References],
      style: "iso-690-numeric",
    )
  ],
)

#include "src/00_intro/introduction.typ"
#include "src/01_scope-and-objectives/default.typ"
#include "src/02_foundations/default.typ"
#include "src/03_experimental-work/default.typ"
#include "src/04_discussion/default.typ"
#include "src/05_conclusion/default.typ"
