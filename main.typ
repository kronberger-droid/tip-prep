#import "template.typ": *
#import "figures/state-machine.typ": tip-prep-fsm
#import "figures/architecture.typ": architecture-diagram
#import "figures/convergence.typ": convergence-plot
#import "figures/qr.typ": repo-qr, repo-short

// Preliminary draft: `todo[...]` marks a spot to fill with real data/wording.
// It renders in the blunt-red accent so gaps are easy to spot; delete the
// helper (and its uses) once everything is filled in.
#let todo(body) = text(fill: rgb("B0533A"), weight: "semibold")[#body]

#show: poster.with(
  title: [
    Automated, reproducible conditioning of SPM tips
  ],
  // subtitle: [Working Title -- Replace Me],
  authors: [
    *Martin Kronberger*, David Kugler, Luca Lezuo, Ulrike Diebold, \
    Gareth Parkinson, Michael Schmid, Jan Balajka, Jiri Pavelec
  ],
  affiliations: [
    Institute of Applied Physics, TU Wien, Wiedner Hauptstraße 8-10/134, 1040 Vienna, Austria \
  ],
  contact: link(
    "mailto:kronberger@iap.tuwien.ac.at",
  )[kronberger\@iap.tuwien.ac.at],
  url: [https://www.tuwien.at/en/phy/iap/surface-physics],
  references: bib-refs("refs.bib"),
)

#panel-columns(
  (
    panel[Motivation][
      The quality and interpretability of scanning probe microscopy data
      critically depend on the tip: a controlled termination yields reproducible
      contrast and renders images comparable with simulation. The procedures used
      to prepare well-defined terminations nevertheless rely on operator expertise
      and vary between individuals, limiting the reproducibility and throughput of
      SPM experiments. Efforts to systematize tip preparation range from
      standardized manual protocols @tewari2017 to machine-learning-driven
      automation @alldritt2022, yet reproducible, operator-independent tip
      conditioning remains the exception.

      #text(rgb("0267A5"), weight: "bold")[Initial objectives], for a Nanonis-controlled STM/nc-AFM @nanonis operated with utilizing a qPlus sensor:

      - *Unattended tip preparation:* a defined termination prepared without operator intervention. In nc-AFM the sharpness of a Cu tip can be assessed from the frequency shift $Delta f$

      - *An optimizable procedure:* each session is documented by its parameters and its outcome, a prerequisite for systematic optimization
    ],

    panel[The Conditioning Routine][
      The routine is a state machine over three apex states: blunt, sharp and
      stable. Conditioning and validation loops are selected according to the
      current state, and each terminates in a measurement of $Delta f$.

      #align(center, tip-prep-fsm(accent: accent, scale: 1.38))

      - *Bias pulse and reposition:*
        the pulse voltage is held fixed, scaled linearly with $Delta f$, or stepped up after repeated cycles without improvement and reset once $Delta f$ improves. Its polarity can be alternated on a fixed period. The tip is then repositioned and re-approached after each pulse, so that each measurement samples an undamaged surface

      - *Check:*
        a reading of $Delta f$ is accepted once its scatter and drift fall below threshold. A single in-band value is not sufficient: it is re-confirmed by further readings, each after a reposition, before the apex is classified as sharp

      - *Stability:*
        the bias voltage is swept through both polarities during continuous scanning at reduced speed, and the apex is accepted as stable only if $Delta f$ returns to its pre-sweep value within tolerance. Otherwise a maximum-amplitude pulse voltage is applied and the apex returns to blunt
    ],

    panel[Framework][
      Built on a controller interface, a registry of parameterized actions and an event bus, the framework makes a conditioning routine *reproducible, portable across hardware, cross-platform, shareable and extendable*.

      #align(center, architecture-diagram(accent: accent, scale: 1.82))

      - *Safe by construction:*
        policies are defined over the tracked machine state, and only actions whose preconditions are satisfied are executed

      - *One interface, any hardware:*
        procedures are written against the `Controller` interface, which abstracts the capabilities of the underlying instrument

      - *Actions as data:*
        actions are addressed by name and parameterized by typed values, so a routine is assembled from generic building blocks rather than hardware-specific instrument calls

      - *Traceable execution:*
        the event bus carries each action with its parameters, duration and result. The same stream drives the interface and the log writer, so a run can be followed live or replayed and analyzed offline

      - *Pluggable analyzers:*
        pure functions from a measurement result to a verdict, so that one detector serves both the live loop and archived runs
    ],
  ),
  (
    // The title makes the claim, so the panel goes straight into the images.
    // What used to be a lead-in paragraph is now one conditions line *under* the
    // row: everything shared by all three scans is stated once, and the captions
    // carry only what differs between them.
    panel[$Delta f$ as a proxy for imaging quality][
      // Bold lead-in like every other panel's opening paragraph. It carries what
      // the title cannot: that this is one surface with three apexes, and that
      // the scans are *not* the runs in the panel below. That last clause is
      // load-bearing and says "below" because the scans now sit above the plot.
      *Three apexes on partially oxidised Cu(110).* Constant-current STM images acquired in
      separate sessions, independent of the conditioning runs shown below.

      // All three are 512x512 crops at a 30 x 30 nm frame, so equal heights make
      // the row uniform and the magnification is controlled across the set.
      // Acquisition parameters live in each caption, not in a shared sentence:
      // the three scans are from separate sessions and need not share a setpoint
      // or a bias. Keep every caption the *same number of lines*, or the row
      // looks ragged and reads as a layout bug.
      #block(above: 1em, grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 0.4em,
        // Quantities are named, not just listed. Note `bold(...)` inside the
        // math: the caption is set bold and math does *not* inherit that, so a
        // bare `$Delta f$` renders a light symbol against a heavy unit.
        figure-img(
          "assets/Cu(110)_bad.png",
          // +1.0 V, opposite polarity to the other two and 5x the magnitude of
          // the sharpest. Current taken as the same ~100 pA as the others.
          [$bold(Delta f)$ = −1.8 Hz, 30 × 30 nm \
            $bold(V)$ = +1.0 V, $bold(I)$ = 100 pA],
          height: 110mm,
        ),
        figure-img(
          "assets/Cu(110)_okay.png",
          // From the file metadata: Bias -0.5 V, Current::Current -105.308 pA,
          // acquired 2025-05-11 over 354 s. Quoted as a magnitude, since
          // Current::Calibration is itself negative (-500E-12 A/V) and the sign
          // therefore says more about the channel convention than the tunnelling
          // direction, which the bias already gives.
          [$bold(Delta f)$ = −1.0 Hz, 30 × 30 nm \
            $bold(V)$ = −0.5 V, $bold(I)$ = 105 pA],
          height: 110mm,
        ),
        figure-img(
          "assets/Cu(110)_good.png",
          // From the file metadata: Bias -0.2 V, Current::Current -100.564 pA,
          // acquired 2026-01-22 over 498 s. Comment reads "SensorJ after crashed
          // to gypsum". Note the bias differs from the middle scan's -0.5 V.
          [$bold(Delta f)$ = −0.6 Hz, 30 × 30 nm \
            $bold(V)$ = −0.2 V, $bold(I)$ = 100 pA],
          height: 110mm,
        ),
      ))
    ],
    // Split back out of Proof of Concept. The GUI is not evidence that a tip got
    // sharp, it is a Framework artefact, and one panel making both claims left
    // the screenshot paragraph orphaned between two figures with no lead-in.
    // The split costs one header plus insets, ~30 mm, which the smaller header
    // inset and the boxed QR had just paid for.
    // The dropped sentence was "Each marker is one accepted Δf measurement on
    // fresh surface": the x axis already reads `Δf read`, and The Conditioning
    // Routine already says the tip moves to a fresh site between reads.
    panel[Proof of Concept][
      *partially oxidised Cu(110).* Two sessions, each run unattended from
      approach to withdrawal starting from a blunt tip, both reaching the sharp
      bounds within 7 min. One apex subsequently passed the bias sweep; the other
      did not, and the loop resumed pulsing.

      #align(center, convergence-plot(accent: accent, scale: 0.96))
    ],

    panel[The App][
      *The same event stream drives the interface.* It displays the live
      $Delta f$ and pulse-voltage histories alongside the parameters that define
      the run, including the sharp bounds used above.

      // `above: 1em`, not the 0.5em the other figure rows use. With the titles
      // over the images rather than under them, the first thing under the intro
      // paragraph is a line of bold text, and at 0.5em it read as a third line of
      // that paragraph instead of as a label on the figure.
      #block(width: 100%, above: 1em, align(center, grid(
        columns: (auto, auto),
        column-gutter: 0.6em,
        align: top,
        // Titles above here, unlike the STM scans. These name the thing rather
        // than describing it, so reading the label first tells you what you are
        // looking at.
        figure-img(
          "assets/app_screenshot_controll.png",
          [live event stream],
          height: 142mm,
          caption-above: true,
        ),
        figure-img(
          "assets/app_screenshot_config.png",
          [run parameters],
          height: 142mm,
          caption-above: true,
        ),
      )))
    ],

    panel[Outlook][
      - *Functional terminations:* extension beyond sharp metal apexes to defined terminations such as CO @gross2009 or CuOx @wiesener2024. The criterion then becomes a structure in an image rather than a single $Delta f$ value

      - *STM without $Delta f$:*
        where no frequency shift is available, image recognition must supply the criterion

      - *Learning from the archive:*
        bias-pulse amplitude, polarity and timing optimized offline against recorded sessions rather than chosen at the instrument, and in time a pulse policy learned from outcomes @alldritt2022 @rashidi2018

      // The QR sits in the bottom-right corner with the last two bullets beside
      // it, rather than taking a row of its own. Typst has no float or
      // shape-outside, so "text wrapping around it" is a two-cell grid: the QR
      // is one cell, everything meant to sit beside it is the other. Worth
      // ~30 mm, because the row is now as tall as the taller of the two cells
      // instead of the sum.
      // `codetastic` emits a 43x43 module symbol for this URL, so 46 mm is
      // ~1.07 mm per module, still well clear of the ~0.4 mm print floor. Do not
      // shrink it further without a scan test.
      // The QR column is a fixed 102 mm, not `auto`. `subbox` is `width: 100%`,
      // and a fluid cell in an `auto` column takes the whole row, which squeezed
      // the bullets to nothing and blew the column up by 640 mm. 102 mm is the
      // URL at 0.7em (92.6 mm, measured) plus the subbox insets.
      #grid(
        columns: (1fr, 102mm),
        column-gutter: 0.9em,
        align: horizon,
        [
          - *Scripts:*
            lifting a procedure out of Rust into a scripting layer over the action registry, so that it can be reviewed, shared and versioned as text

          - *Agentic operation:*
            exposed through a standard tool interface (MCP), the same registry would allow a language model to drive the microscope through the existing action guards
        ],
        subbox(stack(
          dir: ttb,
          spacing: 0.45em,
          align(center, repo-qr(width: 46mm)),
          align(center, text(size: 0.7em)[*Try it:*]),
          align(center, text(size: 0.7em, fill: accent, repo-short)),
        )),
      )
    ],
  ),
)
