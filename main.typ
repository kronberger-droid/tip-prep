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
      The atomic structure and termination of the apex set what an experiment
      can resolve @gross2009. Yet preparing one is tacit operator craft: a feel
      for the pulse that lives in one person's hands, hard to reproduce across
      sessions and harder to transfer between labs. Standardised manual
      protocols @tewari2017 and ML-driven automation @alldritt2022 both push
      against this, yet hands-off conditioning stays the exception.

      *A conditioning routine should be:*

      - *Reproducible:* a run is one script plus its parameters, so the same procedure repeats across sessions and operators instead of being re-derived each time
      - *Portable across hardware:* the recipe targets an instrument-agnostic interface rather than one vendor's API, so it outlives the machine it was written on
      - *Shareable:* script and parameters are both text. They can be versioned, sent to another group, and replayed there
      - *Extendable:* new actions, pulse strategies and image analysers drop in without touching the routine that uses them

      *Key idea:* move the recipe out of the operator's hands and into a script.
    ],

    panel[The Conditioning Loop][
      The routine is a state machine over the tip's quality. It pulses,
      repositions, and measures the frequency shift $Delta f$. Where the
      stability test is enabled, the loop terminates only once the apex has
      passed it.

      #align(center, tip-prep-fsm(accent: accent, scale: 1.5))

      - *Pulse:* a bias pulse held at a fixed voltage, stepped up when the tip stalls, or mapped linearly from $Delta f$
      - *Reposition:* step to a fresh site and re-approach, so every read samples undamaged surface
      - *Check:* a read counts only once its noise and drift fall under threshold. One in the sharp band is re-confirmed 3× on fresh sites
      - *Stability:* the real gate. Ramp the bias $0.2 arrow.r 2.0$ V through both polarities while scanning at 5 nm/s, then re-measure: stable only if $Delta f$ shifts by $<= 0.4$ Hz
      - *Recover:* if the sweep moved the apex, a max-voltage pulse resets the tip and the loop restarts
    ],

    panel[Framework][
      *rusty-tip* @rustytip: an open Rust framework for writing SPM procedures
      as scripts. The conditioning loop above is one such script, not the point
      of the framework.

      #align(center, architecture-diagram(accent: accent, scale: 1.75))

      - *Safe by construction:* the tracked machine state refuses actions whose preconditions are not met, such as pulsing while engaged @nanonis
      - *One interface, any instrument:* the routine talks to `SpmController`, never to a vendor API, so a new backend is one implementation away
      - *Actions as data:* actions are registered by name and take plain values, so a procedure is a list of parameters rather than code. A scripting layer over that registry is the next step
      - *Observable:* every action emits to an event bus feeding the GUI and the log, so a run can be watched live or replayed afterwards
    ],
  ),
  (
    panel[Proof of Concept][
      *Demonstration on #todo[sample system].* Two independent sessions, each
      starting from a blunt tip, run hands-off from approach to withdraw and
      gated on sharpness alone. Every point is a stabilised read, taken on
      fresh surface after each pulse.

      #align(center, convergence-plot(accent: accent, scale: 1.1))

      - *Session 1:* $Delta f$ climbs from $-19.3$ Hz into the $(-2, 0)$ Hz sharp band in *9 pulses over 70 s*
      - *Session 2:* the same again from $-13.8$ Hz, in *5 pulses over 41 s*
      - *Not monotonic:* reads 2, 5 and 6 of session 1 move the wrong way. Pulses that blunt the tip further are simply absorbed by the loop rather than ending the run
      - *The strategy shows:* every pulse fired at $-4.0$ V except one at $-5.0$ V, stepped up in session 1 after the tip stalled for two cycles. The next read came back at $-3.5$ Hz
      - *Still sharp later:* a fresh approach the same afternoon read $-0.7$ to $-1.3$ Hz across four sites
    ],

    panel[Beyond the Frequency Shift][
      $Delta f$ gates the loop while it runs, but it is a thin signal: it says
      the apex is sharp and holds, not what the apex _is_, and on a pure STM it
      does not exist at all. The richer work happens afterwards, against the
      record.

      - *Every run is a record:* each action, its parameters, duration and typed result stream into a JSON event log, so a session replays offline into $Delta f$ traces, pulse histories and cycles-to-sharp
      - *Parameters from the archive:* thresholds, pulse bounds and step counts can be optimised against past sessions rather than guessed at the instrument, then fed straight back in as the next run's input
      - *Analysers are pure functions:* scan frame in, JSON out. The same detector runs live inside the loop or in batch over an archive of past runs
      - *CuOx row detector:* finds the reconstruction stripes on Cu(110) from a local-variance score map and a projection scan over band orientation, for both Cu- and O-terminated tips @wiesener2024

      A finished run stops being an anecdote and becomes the input to the next
      one.
    ],

    panel[Outlook][
      - *Functional terminations:* go past sharp metal apexes to selective terminations such as CuOx. The target is no longer a number in a band but a structure in an image @wiesener2024
      - *STM without $Delta f$:* with no frequency shift to gate on, image recognition has to close the loop on its own
      - *ML-guided pulsing:* learn the pulse policy from outcomes rather than fixed strategies @alldritt2022 @rashidi2018
      - *A recipe language:* with every action already parameterised, a thin scripting layer over the registry would let a procedure be written, diffed and reviewed like any other text
      - *Agents at the instrument:* the same registry exposed as an MCP server is a short step from here, letting a model drive the microscope through exactly the guarded actions a human recipe uses
      - *Cross-lab validation:* run one recipe on different instruments and find out what actually transfers

      #v(0.3em)
      #grid(
        columns: (auto, 1fr),
        column-gutter: 1.2em,
        align: horizon,
        repo-qr(width: 58mm),
        // Three lines on one even rhythm, set as grid rows so the spacing is
        // uniform rather than whatever the paragraph leading happens to give.
        grid(
          rows: 3,
          row-gutter: 0.55em,
          text(weight: "bold")[Try it],
          text(size: 0.85em, fill: accent, repo-short),
          text(size: 0.85em, raw("cargo add rusty-tip")),
        ),
      )
    ],
  ),
  // Give the content-heavy panels more of their column's height.
  weights-left: (0.92, 1.0, 1.18),
  weights-right: (1.23, 0.83, 0.94),
)
