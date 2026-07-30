# Tip-Prep Poster

A0 portrait conference poster for the automated SPM tip-conditioning work.
The science and all the numbers come from `~/Projects/rust/rusty-tip/` — read that
repo before changing any claim on the poster.

## Build

```nu
typst compile main.typ                                    # -> main.pdf
typst compile main.typ --format png --ppi 72 poster-preview.png   # quick look
typst watch main.typ                                      # while editing
```

## Layout

| File | Role |
| --- | --- |
| `main.typ` | content only: panel titles, bullets, weights |
| `template.typ` | `poster`, `panel`, `panel-columns`, `subbox`, `figure-stub`, `bib-refs` |
| `figures/state-machine.typ` | `fletcher` FSM, mirrors `runner.rs` |
| `figures/architecture.typ` | `fletcher` block diagram of the crate |
| `figures/convergence.typ` | `lilaq` Δf plot, data transcribed from `experiments/` |
| `figures/qr.typ` | `codetastic` repo QR, single source for the URL |
| `refs.bib` | only cited entries render, `bib-refs(full: true)` lists everything |
| `experiments/` | raw run logs, ~112 MB, see Data below |
| `scripts/scan_logs.py` | summarise every log, tolerates truncated files |
| `scripts/detail.py` | action-by-action timeline of one run |

Everything sizes off two constants in `template.typ`: `base-size` (28pt) and
`paper-size` ("a0").
Change `base-size` alone to rescale the whole poster, since every other size is
in `em`.

## Template gotchas

- `panel-columns` computes the two columns' heights **independently**.
  Panel boundaries across the two columns will not line up, and they are not
  supposed to. Do not try to force it.
- `weights-left` / `weights-right` distribute *slack*, not content.
  A panel with a short body just gets more whitespace. Once a column has no
  slack left, changing weights stops helping and only moves the overflow from
  one panel to its neighbour. That is where the left column is now.
  `figure-stub` is unused as of this draft, since no placeholder figures
  remain, but the helper is kept in `template.typ`.
- **Typst's IEEE style prints no date for `@software` / `@misc` entries.** The
  `rustytip` and `nanonis` entries carry `year`/`version`, and neither shows up
  in the rendered list. `note` and `howpublished` are ignored too; only `author`,
  `title` and `url` come through. Do not keep re-adding fields hoping the year
  appears. If a year is ever required, the only reliable route is folding it into
  `title`, which looks wrong, or switching bibliography styles.
- `bib-refs` fakes balanced columns by measuring the single-column height and
  capping the block at `h / cols * 1.15`.
  Typst's `columns()` fills greedily top-to-bottom, so without that cap every
  entry stacks into column 1. If a future reference overflows the last column,
  nudge the `1.15` up.
- `todo[...]` renders in the blunt-red accent. Grep for it before printing.
- `panel` fills on the *outer* block, otherwise the grey stops at the end of the
  text instead of the bottom of the stretched row.
- **`panel` sets `clip: true`, so overflow is silent.** A panel with too much
  body does not error and does not spill — it just cuts the bottom off, and the
  missing content is easy to miss in a thumbnail. After adding to any panel,
  look at the *bottom edge* of that panel in the preview. This already ate a
  whole `subbox` once.
- Diagram figures need `set par(justify: false)`. The poster-wide
  `par(justify: true)` is for prose, and it stretches two-word node labels into
  word-gap canyons ("implement    the / trait").
- **The left column is at capacity.** Adding a single wrapped line to any panel
  clips another, and shifting weights only moves the problem along. If you add
  content there, cut content there.
  What actually bought room, in order of how much:
  1. **Deleting a whole `subbox` and folding its content into the bullet that
     already described it.** The stress-test box repeated the `*Stress:*`
     bullet with numbers attached; the bullet now carries the numbers and the
     box is gone. Worth roughly five lines, far more than any reflow.
  2. Merging two `subbox`es into one (each costs its own inset plus the gap).
  3. Inline math instead of a display equation, which costs block spacing above
     *and* below, roughly three lines for one line of content.
  4. Shortening bullets so they stop wrapping.
  Reach for 1 before 4. Trimming words to save a line is fiddly and keeps
  coming back; removing a redundant element is permanent.

## House style

- **No em-dashes in poster text.** Bold lead-in then a colon:
  `- *Reproducible:* one config defines the whole run`, never
  `- *Reproducible* — one config ...`. Where a dash was doing real work mid
  sentence, split into two sentences or use a comma. This applies to prose too,
  not only bullets.
- Bold lead-ins carry the vocabulary. Every bullet on the poster leads with one.

## Content decisions

- **"Motivation"** (was "The Bottleneck"). It used to be three bullets around a
  70 mm figure stub that was never going to be drawn. It now states the problem
  in one paragraph and then names what a conditioning routine should be:
  *reproducible, portable across hardware, shareable, extendable*. Those four
  words are the poster's spine. Framework's bullets deliberately echo them
  (`One trait, any instrument` answers *portable*), and Outlook's
  *Cross-lab recipes* answers *shareable*. If you reword one, check the echo.
- **No before/after SPM images.** They do not exist, so the poster is built
  without them rather than around a placeholder. Proof of Concept carries the
  convergence plot plus five bold-lead findings and stands on its own. Do not
  re-add a stub for images.
- **"The Conditioning Loop"** (was "Pulse & Check").
  The panel now carries the stability check, so the old title undersold it.
- **"Beyond the Frequency Shift"** (was "Tip Quality Metrics").
  The metrics table was a definition list nobody reads and it duplicated what
  the loop panel already says. It is now a short analysis chapter (structured
  logs, pure-function analysers, CuOx row detector) whose only job is to set up
  the Outlook.
- The Outlook's *functional terminations* and *STM without Δf* bullets only land
  if the analysis panel came first, since both need image recognition.
- FSM edge `Sharp -> Stable` reads `sweep survived`, not `quality metrics`,
  now that the metrics concept is gone.
- **Architecture diagram arrow direction.** The safety loop is drawn
  `Controller -> Machine state -> Actions`, not as a free-floating guard box.
  That is the real order: `executor.rs::enforce_preconditions` finds a required
  field `Unknown`, auto-runs a side-effect-free `Query` action against the
  *controller*, and writes the answer back via `apply_to_state`. The controller
  is the source of truth, `MachineState` is the cached model, and the cache is
  what refuses the action. An earlier version drew the guard with no link to the
  controller, which read as if the state came from nowhere.
- **Third backend is dashed on purpose.** `Your SPM / implement the trait` is an
  invitation, not something that ships. Dashed border, white fill, so nobody
  reads it as a supported driver.
- **Pulse strategies are one sentence, not a table.** They briefly had their own
  three-row box, which was accurate but ate the height Framework needed and gave
  the loop panel two competing boxes. The `*Pulse:*` bullet now names all three
  inline. The full behaviour, if it is ever needed again, is `PulseMethod` in
  `controller_types.rs` and `pulse_state.rs::update_voltage`:
  - `Fixed`: voltage never changes
  - `Stepping`: `cycles_before_step` cycles with no significant improvement
    steps the voltage up by `(max - min) / voltage_steps`. Any significant
    *positive* change resets it to `voltage_bounds.0`
  - `Linear`: linear map of Δf onto `voltage_bounds`, clamped to the max
    outside `linear_clamp`
  - all three optionally flip polarity every `switch_every_n_pulses`
- **Say "parameters", not "TOML".** TOML is an implementation detail and dates
  the poster to one serialisation format. The claim is that a run is defined by
  its parameters. The `Config` node in the architecture diagram says
  `parameters` for the same reason.
- **Framework hints, Outlook commits.** Framework's `*Actions as data:*` bullet
  notes that a procedure is already a list of parameters and that a scripting
  layer is the obvious next step. Outlook then spends two bullets on it:
  `*A recipe language:*` and `*Agents at the instrument:*` (the action registry
  exposed as an MCP server). Keep the hint short and the commitment in Outlook,
  not the other way round.
- **`Beyond the Frequency Shift` covers two threads, not one.** Offline
  parameter optimisation against recorded runs, and image analysis. The intro
  and the closing line ("A finished run stops being an anecdote and becomes the
  input to the next one") are written to cover both. If a bullet is added, check
  it still does.

## Cross-panel consistency

These pairings were wrong at some point and were fixed. Re-check them after any
wording change:

- **"Run" means two things.** Motivation's *Shareable* says "the recipe is a text
  file" (the input), while `Beyond the Frequency Shift` says "every run is a
  record" (the output log). Do not let Motivation drift back to "a run is a text
  file"; it collides with the record.
- **Motivation states goals, Framework states mechanisms.** Framework used to
  carry a bullet literally titled *Reproducible*, repeating Motivation's. It is
  now *Observable*, which covers the `Event bus` node that the diagram draws and
  the text had never explained. Every Framework bullet should answer a Motivation
  value or add a mechanism, never restate one.
- **Outlook is future work only.** *Cross-lab recipes* used to promise sharing,
  which Motivation and Framework already claim works today. It is now
  *Cross-lab validation* (run one recipe on different instruments, see what
  transfers), which is genuinely open.
- **Framework hints, Outlook commits, and they must not use the same words.**
  *Actions as data* vs *A recipe language: with every action already
  parameterised...*.
- Diagram sizing: measure against the panel, do not eyeball. Panel inner width
  is **~383 mm**. Use `context { measure(...) }` on a wide scratch page to find
  the scale that fits. The FSM sat at `scale: 1.1` (276 mm, 72% of the panel)
  and looked lost; it is now `1.5` (377 mm). The architecture diagram is `1.75`
  (382.6 mm) and has ~0.4 mm of headroom, so any node that gets wider needs
  `spacing` reduced to pay for it.
- **`lq.diagram(width:)` is the axes width, not the figure width.** Axis labels,
  tick labels and padding add roughly 28 mm on top. `convergence.typ` declares
  `300mm * scale`, so `scale: 1.2` rendered 394 mm and overflowed the 383 mm
  panel, even though 300 × 1.2 = 360 looks safe on paper. It is now `1.1`
  (361 mm measured). Always measure the whole figure, never reason from the
  `width:` argument.
- **Diagram nodes should all be the same number of lines.** A node whose
  subtitle wraps to three lines while its neighbours use two makes the row look
  ragged, which reads as a layout bug rather than a design choice. Two were
  fixed this way: `Your SPM` lost "implement the trait" for "your backend"
  (roughly the length of "offline replay"), and `Actions` was widened to 40 mm
  with `spacing` cut from 13 mm to 11.5 mm to pay for it, so
  "bias · motor · scan" stays on one line.

## QR code

`figures/qr.typ` generates it at compile time with `@preview/codetastic:0.2.2`.
Vector output, so it stays crisp at A0 and there is no PNG asset to drift out of
sync with the URL. Change `repo-url` in that file and everything follows.

Verified with OpenCV's `QRCodeDetector`, which decoded the rendered PDF back to
the exact URL.
Note that `codetastic` emits a **version-7 symbol (43x43 modules)** for this
URL, well above the minimum version 4 a reference encoder picks, so the modules
are smaller than you would expect for the size. At 58 mm that is ~1.3 mm per
module, comfortably above the ~0.4 mm print floor, but do not shrink it much
further.

**Scan the printed proof with a phone before the conference.** A QR that has
only ever existed as a PDF is an untested QR.

## Where the numbers come from

The stability criterion in the loop panel is from
`rusty-tip/configs/tip_prep_with_stability.toml` and `runner.rs::check_stability`:

- confirm sharp 3× with repositioning between reads (`CONFIRMATION_READS`)
- drop scan speed to 5 nm/s, save and restore the original
- bias sweep 0.2 -> 2.0 V, 1000 steps, 200 ms each, both polarities,
  while scanning continuously in bouncy mode
- stable iff `|Δf_after - Δf_before| <= 0.4 Hz`
- otherwise a max-voltage pulse and back to blunt

Those are the shipped config values.
**Re-check them against whichever run ends up in the Proof of Concept panel**
before printing, since a poster that quotes one config and plots another is the
kind of thing a reviewer will catch.

## Data

The real runs live in **`./experiments/` in this repo**.
Look here first.
`rusty-tip/experiments/` is all Nanonis demo mode — Δf identically `0.0`, or
pinned flat at `-5.252 Hz` in the one file that has real TCP frames — and an
early pass on this poster wrongly concluded from it that no data existed at all.

The six December runs, all from the afternoon of 2025-12-12:

| file | cycles | Δf start -> end | outcome |
| --- | --- | --- | --- |
| `150704` | 3 reads | -4.30 -> -4.85 | blunt throughout, truncated |
| `151210` | 2 reads | -5.07 -> -8.71 | got worse, truncated |
| **`151951`** | **9 pulses** | **-19.31 -> -1.29** | **Sharp at 70.5 s** |
| **`152232`** | **5 pulses** | **-13.77 -> -0.85** | **Sharp at 41.4 s** |
| `152457` | 7 reads | -4.21 -> -24.62 | got worse, truncated |
| `155910` | 0 pulses | -0.70 … -0.83 | already sharp, 4 fresh sites |

`151951` and `152232` are the two plotted in `figures/convergence.typ`.
`155910` supplies the "still sharp later that afternoon" bullet.

Three of the six are **truncated JSON**, since the run was killed mid-write, so
`json.load` rejects the whole file.
Decode entry by entry with `JSONDecoder.raw_decode` and stop at the first
failure rather than discarding the file. `scripts/scan_logs.py` does that.

### Caveats on those numbers

- **No stability check ran in any December run.** Every one goes
  `Sharp -> Withdraw` immediately, so `check_stability` was off. The Proof of
  Concept panel must not claim the sweep was passed, and currently does not.
  An earlier draft did claim it, which is exactly the kind of thing that gets
  caught at the poster.
- Sharp bounds in these runs were **(-2.0, 0.0) Hz**, while
  `tip_prep_with_stability.toml` — the source of the sweep parameters quoted in
  the loop panel — uses `(-1.5, 0.0)`. Two different configs. Do not present
  them as one run.
- Pulses were **-4.0 V throughout, with a single -5.0 V** at cycle 6 of `151951`.
  That is barely any adaptation, so the loop panel's "fixed, stepping, or
  Δf-linear" describes what the framework *offers*, not what these traces show.
  Do not point at the plot and call it adaptive.
- Is the `155910` tip the same tip as `152232`? Same afternoon, 35 min later, but
  nothing in the log proves it. Confirm before defending that bullet in person.
- **The December runs stop at the first in-band read.** Both `151951` and
  `152232` go `TipState: Sharp -> Withdraw` with nothing in between: no 3×
  confirmation, no sweep. Today's `runner.rs` calls `confirm_sharp` *before* it
  consults `check_stability`, so current code would do three repositioned reads
  even with the stress test off. The plotted runs predate that, so the poster
  must not claim the confirmation is visible in the data. This is why the loop
  panel opens with "With the stress test switched on, it keeps going until..."
  rather than "only exits once...", and why Proof of Concept says
  **gated on sharpness alone**. Both phrases are load-bearing. Do not tighten
  either into an absolute claim while these are the plotted runs.

### Log formats

Two exist, and they are not interchangeable:

- **JSON array** (Dec 2025, Jan 2026) — `{action, result, start_time,
  duration_ms}` with typed results: `StableSignal` carries `stable_value` and
  `stability_metrics`, `TipState` carries `shape`. This is the plottable one,
  and everything on the poster comes from it.
- **JSONL from the `EventBus`** (Mar 2026) — `action_started` /
  `action_completed` / `custom`. Streamable, but `output` is `null`, so it
  carries timing and the three `tip_prep_state` phase markers and nothing else.

The newer format is the one that would be logged today, and it **cannot
reproduce this figure**.
If future runs should stay plottable, the `EventBus` file logger has to start
serialising `ActionOutput`.

## Still open

Roughly in order of how much they cost the poster:

1. `todo[sample system]`. The demonstration still names no surface. This is the
   last `todo[...]` on the poster.
2. Stability-check data exists but is not on this machine. Once it is here, the
   Proof of Concept can carry the `Sharp -> Stable` half of the FSM, which the
   loop panel asserts and the data panel does not yet evidence. Note that
   dropping it into Proof of Concept costs vertical space the right column has
   but the plot currently uses.
3. Optional: a figure for Motivation. There is no room for one now without
   cutting a bullet, and the four-value list is doing the work a cartoon would.

Both columns are now near capacity, so the earlier note that
`Beyond the Frequency Shift` had room to grow no longer holds. It was filled
with the offline-optimisation bullet. Adding anywhere now means cutting
somewhere in the same column.
