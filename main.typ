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
    Gareth Parkinson, Michael Schmid, Jan. Balajka, Jiri Pavelec
  ],
  affiliations: [
    Institute of Applied Physics, TU Wien, Wiedner Hauptstraße 8-10/134, 1040 Vienna, Austria \
  ],
  contact: [kronberger\@iap.tuwien.at],
  url: [https://kron-berger.com],
  references: bib-refs("refs.bib"),
)

#panel-columns(
  (
    panel[Motivation][
      The quality of scanning probe microscopy data critically depends on the
      tip: controlled functionalization can both increase image contrast and
      simplify the interpretation of images. Yet the procedures to prepare
      well-performing tip terminations rely on operator know-how and vary with
      individual experience, limiting the reproducibility and throughput of SPM
      experiments. Efforts to systematize tip preparation range from standardized
      manual protocols @tewari2017 to machine-learning-driven automation
      @alldritt2022. Reproducible, operator-independent tip conditioning
      nevertheless remains the exception.

      - *Functionalized apexes, unattended:* a deliberate termination prepared with no operator at the keyboard. For a sharp metal apex, quality still reduces to a single observable, which is why it comes first
      - *Long runs that log themselves:* without a record of what was tried, every session is an anecdote and every threshold a guess, so there is nothing to optimize against

      *Key idea:* move the recipe out of the operator's hands and into code.
    ],

    panel[The Conditioning Loop][
      The routine is a state machine over the tip apex: blunt, sharp, or stable.
      It applies bias pulses, repositions, and measures the frequency shift $Delta f$. When the
      stability test is enabled, the loop terminates only once the apex has
      passed it.

      #align(center, tip-prep-fsm(accent: accent, scale: 1.43))

      - *Bias pulse and reposition:* the bias pulse is either held at fixed amplitude, stepped up when $Delta f$ stops improving, or scaled linearly with $Delta f$. The tip then steps to a fresh site and re-approaches, so every measurement samples undamaged surface
      - *Check:* $Delta f$ is accepted only once its noise and drift fall below threshold. A value inside the sharp bounds is re-confirmed on fresh sites before the apex counts as sharp
      - *Stability:* the final criterion. The bias is ramped through both polarities while scanning at reduced speed, and the apex passes only if $Delta f$ returns to its pre-sweep value within tolerance

      Every bound, threshold and count is a parameter of the run, not a constant
      of the method.
    ],

    panel[Framework][
      An open-source Rust framework for writing SPM procedures, built so a
      conditioning routine can be *reproducible, portable across hardware,
      shareable and extendable* rather than depending on one operator's experience.

      #align(center, architecture-diagram(accent: accent, scale: 1.68))

      - *Safe by construction:* the tracked machine state blocks any action whose preconditions are not met, such as a bias pulse while the tip is engaged @nanonis
      - *One interface, any instrument:* the routine calls `SpmController`, never a vendor API, so a new backend is one implementation away
      - *Actions as data:* actions are addressed by name and parameterized by plain values, so a routine is assembled from them rather than from bespoke instrument calls
      - *Every run is a record:* the event bus carries every action with its parameters, duration and typed result into the GUI and a JSON log, so a run can be watched live or replayed offline
      - *Analyzers plug in:* scan frame in, JSON out, as pure functions, so one detector serves both the live loop and archived runs
    ],
  ),
  (
    panel[Proof of Concept][
      *Demonstration on oxygen-reconstructed Cu(110).* Two sessions, each starting from
      a blunt tip and running unattended from approach to withdraw: one came within the
      sharp bounds in *34 bias pulses over 4.7 min*, the other in *287 pulses over
      37 min*. Longer sessions have run for *about an hour*, terminated by the
      operator rather than by the routine. Every point is one accepted $Delta f$
      measurement, taken on fresh surface after a bias pulse. Each run stops as soon as
      its configured window is met, so where a trace ends is the target it was
      given, not a limit of the method.

      #align(center, convergence-plot(accent: accent, scale: 0.98))

      *$Delta f$ as a proxy for imaging quality.* Separate sessions, not the runs
      above: the same surface imaged with three different apexes.

      // All three are 512x512 crops at a 30 x 30 nm frame, so equal heights make
      // the row uniform and the magnification is controlled across the set.
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 0.4em,
        figure-img("assets/Cu(110)_bad.png",
          [−1.8 Hz, 30 × 30 nm], height: 108mm),
        figure-img("assets/Cu(110)_okay.png",
          [−1.0 Hz, 30 × 30 nm], height: 108mm),
        figure-img("assets/Cu(110)_good.png",
          [−0.6 Hz, 30 × 30 nm], height: 108mm),
      )

    ],

    panel[The App][
      The event stream that writes the log also drives the interface: live
      $Delta f$ and pulse-voltage history beside the parameters that define the
      run, including the sharp bounds used in the plot above.

      // Aspect ratios are wildly different (control 1891x1001 = 1.89, config
      // 519x986 = 0.53), so equal heights are the only option that keeps the two
      // titles on one baseline; `columns: (auto, auto)` lets each take its
      // natural width and the whole row is centered. Sizing by width instead
      // would make the config tab ~2.6x taller than the panel can hold.
      #align(center, grid(
        columns: (auto, auto),
        column-gutter: 0.6em,
        align: bottom,
        figure-img("assets/app_screenshot_controll.png",
          [live event stream], height: 130mm),
        figure-img("assets/app_screenshot_config.png",
          [run parameters], height: 130mm),
      ))
    ],

    panel[Outlook][
      - *Functional terminations:* extend beyond sharp metal apexes to controlled terminations such as CO @gross2009 or CuOx @wiesener2024. The criterion becomes a structure in an image rather than a single number, and a detector for the Cu(110) rows is a first step
      - *STM without $Delta f$:* with no frequency shift available, image recognition must close the loop on its own
      - *Learning from the archive:* bias-pulse amplitude, polarity and timing optimized offline against past sessions rather than guessed at the instrument, and in time a pulse policy learned from outcomes @alldritt2022 @rashidi2018
      - *Scripts, then agents:* lifting a procedure out of Rust into a scripting layer over the action registry would let it be written, versioned and reviewed like any other text. Exposed through a standard tool interface, that same registry would let a language model drive the microscope through those guarded actions

      // Tucked in beside the closing text rather than given its own row. The QR
      // was 58 mm with a three-line caption stacked next to it, ~60 mm of
      // dedicated height; at 46 mm with two lines it costs ~46 mm, and the
      // height the right column needed came out of here and out of merging two
      // pairs of Outlook bullets. `codetastic` emits a 43x43 module symbol for
      // this URL, so 46 mm is ~1.07 mm per module, still well clear of the
      // ~0.4 mm print floor. Do not shrink it further without a scan test.
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.9em,
        align: horizon,
        repo-qr(width: 46mm),
        grid(
          rows: 2,
          row-gutter: 0.5em,
          text(size: 0.92em)[*Try it:* #text(fill: accent, repo-short)],
          text(size: 0.85em, raw("cargo add rusty-tip")),
        ),
      )
    ],
  ),
  // Give the content-heavy panels more of their column's height.
  weights-left: (0.79, 1.09, 1.21),
  weights-right: (1.80, 0.82, 0.98),
)
