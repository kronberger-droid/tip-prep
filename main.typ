#import "template.typ": *

#show: poster.with(
  title: [
    Automated, reproducible conditioning of SPM tips
  ],
  // subtitle: [Working Title -- Replace Me],
  authors: [
    *Martin Kronberger*, David Kugler, Luca Lezuo, Ulrike Diebold, \
    Gareth Parkinson, Michael Schmid, Jan. Balajka, Jiri Pavelec
  ],
  affiliations: [
    Institute of Applied Physics, TU Wien, Wiedner Hauptstraße 8-10/134, 1040 Vienna, Austria \
  ],
  contact: [kronberger\@iap.tuwien.at],
  url: [https://www.github.com/kronberger-droid],
  references: bib-refs("refs.bib"),
)

// Panels are split into two independent columns. Each column fills the full
// body height on its own, so the left column's three panels and the right
// column's two panels no longer share row heights. Optionally pass
// `weights-left` / `weights-right` (one number per panel) to size them
// unequally within a column.
#panel-columns(
  (
    panel[Motivation][
      - Why tip preparation matters @binnig1986
      - What limits current methods @giessibl2003
      - Goal of this work

      #figure-stub("sketch / schematic", height: 70mm)

      *Key question:* how does preparation route affect tip apex quality?
    ],

    panel[Experimental Methods][
      #grid(
        columns: (1fr, 1fr),
        gutter: 8pt,
        figure-stub("setup photo", height: 55mm),
        figure-stub("process diagram", height: 55mm),
      )

      - Step one of the procedure
      - Step two of the procedure
      - Parameters: $T = 300 med "K"$, $p = 10^(-9) med "mbar"$
    ],

    panel[Results and Conclusions][
      #figure-stub("main result plot", height: 80mm)

      - Result one, consistent with @example2024
      - Result two
      - Conclusion / outlook
    ],
  ),
  (
    panel[Sample Characterisation][
      #figure-stub("SEM / AFM images", height: 80mm)

      #subbox[
        #table(
          columns: 3,
          stroke: 0.4pt + gray,
          table.header([*Sample*], [*RMS (nm)*], [*Note*]),
          [A], [0.8], [as-prepared],
          [B], [1.4], [annealed],
          [C], [2.1], [sputtered],
        )
      ]
    ],

    panel[Discussion][
      Longer narrative panel. Because the right column only holds two panels,
      each gets half the page height, independent of the three-way split on
      the left.

      - Point one
      - Point two
    ],
  ),
)
