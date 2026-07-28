#import "template.typ": *
#import "figures/state-machine.typ": tip-prep-fsm
#import "figures/architecture.typ": architecture-diagram

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
    Gareth Parkinson, Michael Schmid, Jan. Balajka, Jiri Pavelec
  ],
  affiliations: [
    Institute of Applied Physics, TU Wien, Wiedner Hauptstraße 8-10/134, 1040 Vienna, Austria \
  ],
  contact: [kronberger\@iap.tuwien.at],
  url: [https://www.github.com/kronberger-droid],
  references: bib-refs("refs.bib"),
)

#panel-columns(
  (
    panel[The Bottleneck][
      - The atomic structure and termination of the tip set what an experiment can resolve @gross2009
      - Yet preparing a good or specifically terminated tip is tacit operator craft: hard to reproduce across sessions, hard to transfer between labs
      - Prior art spans standardized manual protocols @tewari2017 and ML-driven automation @alldritt2022, yet hands-off, reproducible conditioning stays the exception

      #figure-stub(
        "tip apex → image quality (convolution cartoon)",
        height: 70mm,
      )

      *Key idea:* turn a working recipe into a replayable, shareable artifact.
    ],

    panel[Pulse & Check][
      The routine runs as a state machine: pulse, reposition, and measure the
      frequency shift $Delta f$, looping until the tip is confirmed sharp and
      stable.

      #align(center, tip-prep-fsm(accent: accent, scale: 1.4))

      - *Pulse* — a bias pulse at the current voltage; magnitude follows a configurable strategy (fixed, stepping, or $Delta f$-linear)
      - *Reposition* — step to a fresh surface site and re-approach, so every reading samples undamaged surface
      - *Check* — read a stabilised $Delta f$; a value inside the sharp band triggers a 3× confirmation before the stability test
      - *Recover* — if a stability sweep shows the apex drifting, a max-voltage pulse resets the tip and the loop restarts
    ],

    panel[Framework][
      *rusty-tip* — an open, config-driven Rust framework that turns a working
      recipe into a replayable artifact.

      #align(center, architecture-diagram(accent: accent, scale: 1.65))

      - *Safe by construction* — the tracked machine state refuses actions whose preconditions are not met (e.g. pulsing while engaged) @nanonis
      - *Reproducible* — a whole run is defined by one TOML config: versioned, shareable, re-runnable
    ],
  ),
  (
    panel[Proof of Concept][
      *Demonstration on #todo[sample system].* Starting from a deliberately
      blunt tip, the routine recovers atomic-scale contrast with no operator
      input.

      #figure-stub("SPM images - Before & After", height: 62mm)

      - $Delta f$ converges into the sharp band within #todo[$approx N$] pulse cycles
      - Sharpness confirmed and held through the stability sweeps
      - Reproduced across #todo[$M$] independent sessions

      #figure-stub("Freq. Shift Plot (converging)", height: 62mm)
    ],

    panel[Tip Quality Metrics][
      What counts as a good tip? Quality is scored from the frequency-shift
      signal and cross-checked against imaging.

      #subbox[
        #table(
          columns: (auto, 1fr),
          stroke: 0.4pt + gray,
          align: (left, left),
          table.header([*Metric*], [*Definition*]),
          [Sharpness], [$Delta f$ inside the target band],
          [Stability], [$Delta f$ drift $<=$ threshold across bias sweeps],
          [Convergence], [pulse cycles to reach a sharp, stable tip],
          [Reproducibility], [success rate across sessions and operators],
        )
      ]

      - Thresholds are set in the config, so the same bar applies every run
      - #todo[Add a representative distribution: cycles-to-sharp or success rate]
    ],

    panel[Outlook][
      - *Functional terminations* — extend beyond sharp metal apexes to selective terminations such as CuOx @wiesener2024
      - *ML-guided pulsing* — learn the pulse policy from outcomes rather than fixed strategies @alldritt2022 @rashidi2018
      - *Cross-lab recipes* — share and replay conditioning configs between instruments and groups
      - *Closed-loop quality* — fold image-based scoring back into the stopping criterion

      *Try it:* #todo[repo / QR link]
    ],
  ),
  // Give the content-heavy panels more of their column's height.
  weights-left: (0.85, 1.05, 1.1),
  weights-right: (1.25, 1.0, 0.85),
)
