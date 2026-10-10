#import "template.typ": *
#import "figures/state-machine.typ": tip-prep-fsm
#import "figures/architecture.typ": architecture-diagram
#import "figures/convergence.typ": convergence-plot
#import "figures/qr.typ": repo-qr, repo-short

#let todo(body) = text(fill: rgb("B0533A"), weight: "semibold")[#body]

#show: poster.with(
  title: [
    Automated, reproducible conditioning of SPM tips
  ],
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
      The quality and interpretability of scanning probe microscopy (SPM) data critically depend on the tip termination. Controlled functionalization provides reproducible contrast and makes surface structures comparable with computational modeling, and copper-oxide surfaces are among the best-defined systems for it.
      Preparing a well-functionalized tip is nevertheless time-consuming and strongly dependent on operator experience, limiting reproducibility and throughput.
      Efforts to systematize it range from standardized preparation procedures @tewari2017 to machine-learning-assisted automation @alldritt2022, yet operator-independent conditioning remains the exception. Here, we present the first steps towards autonomous functionalization of SPM tips.

      #text(rgb("0267A5"), weight: "bold")[Initial objectives], for a Nanonis-controlled STM/nc-AFM @nanonis operated with a qPlus sensor:

      - *Unattended tip preparation:* a defined termination prepared without operator intervention. In nc-AFM the sharpness of a Cu tip can be assessed from the frequency shift $Delta f$ @giessibl2003

      - *An optimizable procedure:* the parameters and outcome of every preparation cycle are recorded, providing the basis for systematic, data-driven optimization
    ],

    panel[The Conditioning Routine][
      The routine is a state machine over three apex states: blunt, sharp and
      stable. Conditioning and validation loops are selected according to the
      current state, and each terminates in a measurement of $Delta f$.

      #align(center, tip-prep-fsm(accent: accent, scale: 1.38))

      - *Bias pulsing and repositioning:*
        the pulse voltage is either held fixed or adjusted according to $Delta f$, by scaling with it directly or by stepping up after repeated cycles without improvement and resetting once the tip improves. Its polarity can be alternated on a fixed period. After each pulse the tip is moved to a fresh surface area before the next measurement

      - *Sharpness check:*
        $Delta f$ is accepted once the signal has settled. Several in-bounds measurements at different positions are required before the tip is classified as sharp

      - *Stability test:*
        the bias is swept through both polarities during slow scanning. The tip is classified as stable only if $Delta f$ returns to its initial value within tolerance; otherwise a strong voltage pulse resets it to the blunt state
    ],

    panel[Framework][
      Built on a controller interface, a registry of parameterized actions and an event bus, the framework makes a conditioning routine *reproducible, portable across instruments, cross-platform, shareable and extendable*.

      #align(center, architecture-diagram(accent: accent, scale: 1.82))

      - *Safe by design:*
        the machine state is tracked and refreshed against the instrument on demand. Actions are executed only when their preconditions are satisfied

      - *One interface, any instrument:*
        procedures use a common `Controller` interface that abstracts the capabilities of the underlying instrument

      - *Actions as data:*
        actions are identified by name and defined by typed parameters. Routines are built from registered actions rather than hardware-specific commands

      - *Traceable execution:*
        the event bus carries each action, its parameters, duration and result. The same data stream supports live monitoring, logging, replay and offline analysis

      - *Pluggable analyzers:*
        pure functions convert measurement results into decisions. The same analyzer can be used in the live routine and on archived data
    ],
  ),
  (
    panel[$Delta f$ as a proxy for imaging quality][
      *Three apexes on partially oxidized Cu(110).* Constant-current STM images acquired in
      separate sessions, independent of the conditioning runs shown below.

      #block(above: 1em, grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 0.4em,
        figure-img(
          "assets/Cu(110)_bad.png",
          [$bold(Delta f)$ = −1.8 Hz, 30 × 30 nm \
            $bold(V)$ = +1.0 V, $bold(I)$ = 100 pA],
          height: 110mm,
          stamp: [24/01/04 \ Cu(110)\_00090],
        ),
        figure-img(
          "assets/Cu(110)_okay.png",
          [$bold(Delta f)$ = −1.0 Hz, 30 × 30 nm \
            $bold(V)$ = −0.5 V, $bold(I)$ = 105 pA],
          height: 110mm,
          stamp: [25/05/11 \ CaSiO3/WO14.1/Cu(110)\_00157],
        ),
        figure-img(
          "assets/Cu(110)_good.png",
          [$bold(Delta f)$ = −0.6 Hz, 30 × 30 nm \
            $bold(V)$ = −0.2 V, $bold(I)$ = 100 pA],
          height: 110mm,
          stamp: [26/01/22 \ Gypsum\_A12\_0048],
        ),
      ))
    ],
    panel[Proof of Concept][
      *Partially oxidized Cu(110).* Two unattended runs started with blunt tips
      and reached the sharp bounds within 7 min. One tip passed the stability
      test; the other automatically returned to pulsing. The routine has also run
      safely for over an hour on tips that never reached the bounds.

      #align(center, convergence-plot(accent: accent, scale: 0.96))
    ],

    panel[The App][
      *The user interface is built directly on the event bus.* It displays the live
      $Delta f$ and pulse-voltage histories alongside the parameters that define
      the run.

      #block(width: 100%, above: 1em, align(center, grid(
        columns: (auto, auto),
        column-gutter: 0.6em,
        align: top,
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

      - *Learning from archived runs:*
        bias-pulse amplitude, polarity and timing can be optimized offline using recorded sessions. Ultimately, the pulse strategy could be learned directly from previous outcomes @alldritt2022 @rashidi2018

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
