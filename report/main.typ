#import "report.typ": list-of-figures, list-of-tables, report
#import "lib.typ": *
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/unify:0.8.1": num, qty

#show: report.with(
  title: [ Automated, Reproducible Conditioning of SPM Tips ],
  advisors: (
    [ Ing. David Kugler ],
    [ Dipl.-Ing. Luca Lezuo ],
    [ Dr.techn. Jan Balajka ],
    [ Dr.techn. Jiri Pavelec ],
  ),
  authors: ([ Martin Kronberger ],),
  matriculation: [ Matr.-Nr.: 12202316 ],
  supervisor: [ Dr.techn. Jiri Pavelec ],
  date: datetime.today(),

  // Read on screen, not printed: symmetric margins, no blank versos, and a
  // fixed header.
  two-sided: false,

  front-matter: [
    #include "src/00_intro/declaration.typ"
    #pagebreak()
    #include "src/00_intro/abstract.typ"
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
#include "src/02_foundations/default.typ"
#include "src/03_instrument-interface/default.typ"
#include "src/04_framework/default.typ"
#include "src/05_routine/default.typ"
#include "src/06_validation/default.typ"
#include "src/07_discussion/default.typ"
#include "src/08_outlook/default.typ"
#include "src/09_conclusion/default.typ"
