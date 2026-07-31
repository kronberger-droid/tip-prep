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
| `template.typ` | `poster`, `panel`, `panel-columns`, `subbox`, `figure-stub`, `figure-img`, `bib-refs` |
| `figures/state-machine.typ` | `fletcher` FSM, mirrors `runner.rs` |
| `figures/architecture.typ` | `fletcher` block diagram of the crate |
| `figures/convergence.typ` | `lilaq` Δf plot; reads `traces.json`, no numbers inline |
| `figures/traces.json` | generated Δf traces + provenance, committed so the poster builds without the drive |
| `figures/qr.typ` | `codetastic` repo QR, single source for the URL |
| `assets/` | logos, plus the Cu(110) STM scans used in Proof of Concept |
| `refs.bib` | only cited entries render, `bib-refs(full: true)` lists everything |
| `experiments/` | gitignored; one demo-mode file. Real archive is on the DATA drive, see Data below |
| `scripts/scan_logs.py` | summarise every log, tolerates truncated files |
| `scripts/detail.py` | action-by-action timeline of one run |
| `scripts/index_logs.py` | index a whole log *drive* into a cache, then rank runs |
| `scripts/extract_trace.py` | pull one run's Δf trace into `figures/traces.json` |

Everything sizes off two constants in `template.typ`: `base-size` (28pt) and
`paper-size` ("a0").
Change `base-size` alone to rescale the whole poster, since every other size is
in `em`.

## Template gotchas

- `panel-columns` computes the two columns' heights **independently**.
  Panel boundaries across the two columns will not line up, and they are not
  supposed to. Do not try to force it.
- **Row heights are measured, and `weights-*` are gone from `main.typ`.**
  `panel-column` lays each panel out once at `h: auto` to find its natural
  height, then sets `rows: h_i * 1fr`, so the column's spare space is handed out
  in proportion to what each panel actually holds. Adding a bullet or resizing a
  figure re-balances the column on the next build with nothing to retune.
  The hand-tuned numbers were only ever an estimate of this: the last set,
  `(0.74, 1.55, 0.99)`, is the measured ratio `194 : 406 : 242` rounded by eye.
  Three things follow, and the second is the one that matters:
  1. **A panel is a closure, not content.** `panel[Title][Body]` now returns
     `(h: 100%) => block(...)`, and `panel-column` calls it twice, once to
     measure and once to render. The call site did not change, but anything that
     treats a panel as finished content will not work. `panel-column` falls back
     to using a non-function entry as-is, so a plain block can still sit in a
     column.
  2. **An overfull column is a build error**, with the overflow in mm. It used
     to be silent (see the `clip: true` note below). Expect ~3 spurious
     "citation could not be located" errors alongside the panic, since the run
     aborts before citations resolve; the panic is the real one.
  3. `weights-left` / `weights-right` still work and still override, for the
     cases where the honest proportional answer is not the wanted one. They skip
     the sizing, not the overfull check. Prefer leaving them off.
  Cost is one extra layout pass over the whole poster, about 25% of the build
  (1.0 s to 1.3 s), which at this size is not worth optimising.
  `figure-stub` is in use again, three times, all inside `todo[...]`.
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
- **`panel` still sets `clip: true`, but a whole column can no longer overflow in
  silence.** `panel-column` panics with the amount, which is what that check
  exists for: silent clipping ate a whole `subbox` once and a GUI screenshot
  another time. What the check does *not* catch is a single panel whose row is
  large enough but whose *content* is laid out taller than the measurement
  predicted, so keep glancing at the bottom edge of a panel after adding to it.
- Diagram figures need `set par(justify: false)`. The poster-wide
  `par(justify: true)` is for prose, and it stretches two-word node labels into
  word-gap canyons ("implement    the / trait").
- **Both columns are near capacity**, and the measured layout does not change
  that: it only turns "a neighbour quietly loses its last line" into a build
  error. Adding to a column still means cutting from the same column, since the
  two are sized independently.
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
- **The two columns hold different amounts, so put new figures on the right.**
  Left is Motivation / The Conditioning Loop / Framework. Right is the Δf-proxy
  scan row / Proof of Concept / Outlook, and it is where all four image slots
  ended up. The GUI screenshot was first drafted into Framework, where it belongs
  semantically, and it **silently vanished** under `clip: true` because the left
  column was already ~70 mm over. That failure mode is now a build error.
  **The GUI screenshots and the STM scans are sized against each other**, and the
  stated requirement is that the screenshots be the taller pair: **142 mm**
  against the scans' **110 mm**. Width caps the screenshots at ~156 mm (the two
  aspect ratios sum to 2.42, so 2.42 x height plus the gutter has to stay under
  ~383 mm), but the panel's own height has always been the binding constraint.
  With the measured layout the current slack is 12 / 15 / 18 mm left and
  13 / 23 / 22 mm right, graded by panel size, which is the proportional split
  doing its job. Both figure heights were raised into that slack after The App
  was merged into Proof of Concept; if a panel is split back out, re-check them.
- **Image titles go underneath, and the gap needs `stack`.** Titles were briefly
  above the images. More importantly, `figure-img` originally emitted the caption
  and the image as two consecutive `align()` calls, which are separate *blocks* and
  so pick up the poster-wide paragraph spacing between them. That left a visible
  gulf between an image and its own title, which reads as two unrelated elements.
  It now uses `stack(dir: ttb, spacing: 0.35em, …)`, where the spacing is explicit.
  If a caption ever drifts away from its image again, this is why.
- **An image row sized to the panel eats its own captions first.** In The App the
  screenshots were 130 mm and the two titles underneath ended 1.7 mm above the
  panel border, so the descenders were clipped and the row read as unlabelled.
  This is the failure mode `clip: true` hides: the images look fine, and only the
  caption, the last thing in the flow, is cut. **After changing any image height,
  check the caption, not the image.**
  Two things bought the space back, worth ~16 mm together:
  1. `height: 130mm` -> `114mm` on both screenshots. Caption-to-border went
     4.5 -> 12.4 mm; the response is close to 1:1 in mm once the row is no
     longer overflowing.
  2. `#block(width: 100%, above: 0.5em, …)` around the figure row. The poster
     sets `par(justify: true)` for prose and inherits Typst's default paragraph
     spacing (~1.2em, ~12 mm at `base-size`), which is far more air than a
     figure needs under its intro sentence. Worth ~7 mm anywhere a figure
     follows a paragraph.
     **`width: 100%` is not optional there.** A bare `block(…)` shrinks to its
     content and sits at the start of the line, so the `align(center, …)` inside
     it centres the grid within a box that is itself hard against the left
     inset, and the whole row silently goes left-aligned. It only shows up once
     the row is narrower than the panel, which is exactly what shrinking the
     images did.
  `scripts/`-adjacent tooling for this lives nowhere; measuring it is a one-off.
  Render at `--ppi 45`, find the panel's accent header band and its bottom rule,
  then walk up for the last row carrying ink. Do not try to reason about it from
  `measure()`: the grid's `auto` columns are fluid, so `measure()` reports the
  images' natural combined width (~320 mm) while layout hands them the full
  ~383 mm and letterboxes each image inside its cell. The *box* height is still
  the `height:` you passed, which is the number that matters here.
- **Size a row of images by `height`, never by width.** `figure-img` takes a
  `height` for this reason. The two Cu(110) scans are 609x514 and 618x514, so
  equal widths give unequal heights and the captions underneath sit on different
  baselines, which reads as a broken grid. Equal heights cost a couple of mm of
  unused width per box instead, which nobody notices.
- **The STM scans carry burned-in colourbars.** Roughly 23% of each file's width
  is the pm scale and its tick labels. Three across a 383 mm panel means each
  image is ~105 mm wide, of which only ~81 mm is the actual scan, and the tick
  labels land around 1.7 mm tall, which is unreadable in print. If the images
  need to be bigger, cropping the colourbars off and quoting one z-range in the
  caption buys ~23% of the width back for free. Note the two scans are also on
  **different z-scales** (+69/-56 pm and +70/-139 pm), so a side-by-side
  contrast comparison is partly a scaling artefact, not only a tip difference.
- **The two cheapest levers on this poster are both structural, not editorial.**
  In order of return per unit of effort:
  1. **The panel header inset**, `panel`'s `inset: (x: 1em, y: 0.55em)`, down from
     `0.8em`. ~5 mm per panel, so ~15-20 mm per column, for one number and no
     content. The bar is a label, not a band; at 36pt the glyphs carry their own
     leading. **Do not push it below ~0.5em**, the title starts to touch the rule.
  2. **Putting a fixed-size block beside text instead of above it.** Typst has no
     float and no `shape-outside`, so this is always a two-cell `grid`: the block
     in one cell, everything meant to sit beside it in the other. The row is then
     as tall as the taller cell rather than the sum. The Outlook QR moved this
     way and paid ~30 mm.
     **The trap: the cell holding the block must have an explicit width.** Both
     `subbox` and `figure-img`'s `align(center, …)` are `width: 100%`, and a
     fluid cell in an `auto` column claims the whole row, squeezing the `1fr`
     text cell to nothing. Doing this to the QR blew the column up by 640 mm.
     `columns: (1fr, 102mm)`, not `(1fr, auto)`.
- **Panel count per column is a bigger lever than bullet length.** Deleting a
  panel from one column while growing the other makes the two columns lopsided
  in a way no amount of trimming fixes, and merging two panels recovers a header
  plus a gutter (~60 mm) for free. Both moves in this restructure were panel
  moves, not word cuts.

## House style

- **Paper register, not blog register.** Reviewer feedback, and it applies to
  every panel. State the fact, drop the rhetorical framing, and prefer a short
  clause to a memorable one. What was cut and what replaced it:

  | out | in |
  | --- | --- |
  | "prepared with no operator at the keyboard" | "prepared without operator intervention" |
  | "every session is an anecdote and every threshold a guess" | "records its parameters and its outcome, which is the prerequisite for optimizing either" |
  | "move the recipe out of the operator's hands and into code" | "specify the conditioning procedure in code rather than in operator practice" |

  The pattern in all three: a figure of speech was carrying the argument. Say
  what the sentence means instead. Bullets should read closer to a slide than to
  prose, so cut connectives (`only once`, `which is why`, `on its own`) wherever
  they are not doing logical work.
  **This is a standing instruction, not a one-time pass.** New text gets written
  in this register.

  A full pass on 2026-07-31 took every panel to paper register. The recurring
  faults, worth checking against any new bullet:
  - **Sentence fragments after a bold lead-in.** `*Pluggable analyzers:* as pure
    functions from…` and `*Scripts:* abstracting a procedure out of…`. A lead-in
    is a label, so what follows still has to be a clause.
  - **Dangling participles.** "using the tracked machine state policies can be
    defined" -> "policies are defined over the tracked machine state".
  - **`which is what`, `at the end of which`, `so it is`.** Split the sentence
    instead. *Traceable execution* became two sentences and reads better.
  - **Telegraphic noun stacks.** "blunt tip to withdraw" -> "run unattended from
    approach to withdrawal starting from a blunt tip"; "Same surface, three
    apexes" -> "Three apexes on the same surface".
  - **Elliptical verbs.** "the other moved" -> "the other did not".
  - Grammar slips fixed in the same pass: `sweeped` -> `swept`, `to re-approaches`
    -> `and re-approached`, `hardware specific` -> `hardware-specific`,
    `a given hardware` -> `the underlying instrument`, `(mcp)` -> `(MCP)`,
    `nanonis` -> `Nanonis`, `Q+` -> `qPlus`.
  - **Scare quotes are informal.** `the "sharpness" of a Cu tip` -> `the sharpness
    of a Cu tip`. If a term needs distancing, define it instead.
  Deliberately left alone: `Try it:` on the QR block, which is a call to action
  and not prose, and the lowercase `bias pulse and reposition` / `check` /
  `stability` annotations under the FSM, where lowercase is what marks them as
  annotations rather than headings.
- **The procedures are Rust code today, not scripts.** The word `script` is gone
  from the poster: Framework says "for writing SPM procedures", Motivation's key
  idea says "into code", and *Actions as data* says a routine is "assembled from"
  registered actions rather than claiming a procedure is already a list of
  parameters. The move out of Rust belongs to **Outlook** and is phrased
  conditionally there ("lifting a procedure out of Rust into plain parameters
  *would* let it be versioned…"). This is the author's call and it is also what
  `runner.rs` shows: it constructs action structs in Rust and never touches the
  registry. Do not reintroduce "as scripts" in Framework.
- **Never call it "convergence".** The loop is closer to a random search than to
  a converging process: the long run wanders between -20 and -3 Hz for ~280
  cycles and then lands in the band in the last ten, with no trend in between.
  Say *reached the band*, *landed in the band*, *needed N pulses*. Not
  *converged*, not *approaches* of the gradual kind. This is the author's own
  framing and it is also just what the trace shows.
  The word survives in **internal names only**, where it is now wrong but cheap
  to leave: `figures/convergence.typ` and `convergence-plot()`. Renaming those
  touches `main.typ`'s import; worth doing if anyone is in there anyway.
  `index_logs.py` used to print `converged +3.3 Hz` as a verdict and now prints
  `reached band`. **No poster-visible text has ever used the word**, which was
  checked, not assumed.
- **American English**, to match the submitted abstract (`functionalization`,
  `systematize`, `standardized`, `optimize`, `Analyzers`). The poster was briefly
  all-British and internally consistent, which still left it diverging from the
  abstract. Abstract wins.
- **"bounds", never "band".** The Δf acceptance window is the **sharp bounds**,
  matching the GUI's own `Sharp Tip Bounds (Hz)` field, and a measurement is
  **in bounds** or **out of bounds**. "band" was the earlier term and it reads as
  an *energy* band to a physics audience. Changed in four places plus the plot
  legend and three FSM edge labels. Older notes further down this file may still
  say "band"; the poster does not.
- **"measurement", not "read".** `read` is lab shorthand. The FSM edge
  `re-read out of bounds` is the one survivor, where it names the repeated action
  and the label has to stay short.
- **The four words for "the method" are a deliberate split**, from the abstract
  decision log, and the poster now honours it:
  - **recipe** = the tacit, operator-held know-how. Problem side, Motivation only
  - **procedure** = the shareable written artefact. Solution side
  - **routine** = the framework's executable unit
  - **protocol** = prior-art standardised methods, i.e. `@tewari2017`
  Outlook used to say `recipe` for the shareable artefact, which crossed the first
  two. It now says `procedure`, and the bullet is `*Procedures, then agents:*`.
- **No em-dashes in poster text.** Bold lead-in then a colon:
  `- *Reproducible:* one config defines the whole run`, never
  `- *Reproducible* — one config ...`. Where a dash was doing real work mid
  sentence, split into two sentences or use a comma. This applies to prose too,
  not only bullets.
- Bold lead-ins carry the vocabulary. Every bullet on the poster leads with one.

## The abstract is the source for Motivation

The submitted NC-AFM 2026 abstract is
**`~/Documents/work/university/seminars/abstract_kronberger_NCAFM2026.pdf`**
(drafts and Jan's tracked comments are in the same folder; a decision log is at
`~/Documents/notes/general-vault/_context/claude/session-2026-05-21-ncafm2026-abstract.md`).

**Motivation's opening paragraph now tracks the abstract almost verbatim**, on
purpose, so the poster and the abstract cannot drift apart. Only two changes:
British spelling to match the rest of the poster (`functionalisation`,
`systematise`, `standardised`), and the citation keys. If the abstract is
revised, revise this paragraph with it.

Citation placement follows the abstract too: its first sentence carries **no**
citation, so `@gross2009` moved out of Motivation and into Outlook's *Functional
terminations* bullet next to `@wiesener2024`, matching the abstract's `[5, 6]`
on the future-work sentence (Gross = CO tips, Wiesener = CuOx).

**On run length: the archive's durations are floors, not ceilings.** The abstract
says "We demonstrated unattended **multi-hour** operation", which the logs alone
do not show. What they show:

| | |
| --- | --- |
| longest run of any kind | `20260128_093447`, **111 min**, 779 pulses |
| longest run that ended in the band | `20251213_124835`, **44 min** |
| plotted long run | 37 min |
| runs over 30 min | 5 of 68 |
| runs over 60 min | 1 of 68 |

**The reason nothing runs longer is the operator, not the routine.** Per the
author: these were test runs and were cancelled by hand a lot. None of the long
runs is truncated, so they ended deliberately. That means duration is not evidence
of a limit, and "the loop stopped after 37 min" would be the wrong reading.

**Sanctioned phrasing: "around an hour".** Proof of Concept now carries "Other
sessions have run unattended for *around an hour*, most of them test runs cut
short by hand rather than by the routine." That is supported (5 runs over 30 min,
one at 111 min) and it puts the honest reason in the same sentence. Do not
upgrade it to "multi-hour" on the poster even though the abstract says so, and do
not downgrade it to "37 min" either, which is a fact about one plotted trace
rather than about the framework.

## Content decisions

- **"Motivation"** (was "The Bottleneck"). It used to be three bullets around a
  70 mm figure stub that was never going to be drawn, then a problem paragraph
  plus the four-value list. It now states the problem in one paragraph and then
  *The aim:* in two bullets: **functionalised apexes prepared unattended** (a
  sharp metal tip is only the case that can still be gated on one number, so it
  is where the groundwork gets laid), and **long runs that log themselves**
  (without a record every session is an anecdote, so there is nothing to
  optimise against). That is the real origin of the project and it was missing
  from the poster entirely.
- **The four values live in Framework now**, not Motivation. *reproducible,
  portable across hardware, shareable, extendable* are still the poster's spine,
  but they are the answer to "why is the framework built this way", so they sit
  in Framework's opening sentence. They were **not** moved as four bullets on
  purpose: Framework's mechanism bullets were already written to echo them
  (`One interface, any instrument` answers *portable*), so bulleting the values
  in the same panel produces four pairs of near-duplicates. Stated once in the
  intro they cost one line instead of eight, which is what paid for the
  restructure. If you reword one, check the echo in the bullets below it.
- **SPM images and a GUI screenshot are now planned**, reversing the earlier
  "no before/after images, do not re-add a stub" decision. That call was made
  because the images did not exist; they are being produced. Three
  `figure-stub`s hold the space, all wrapped in `todo[...]` so they show up red:
  two in Proof of Concept (before / after conditioning) and one in `The App`.
  **If the images never arrive, delete the stubs and the `The App` panel** and
  rebalance, rather than printing a poster with dashed grey boxes on it.
- **The framework is never named on the poster.** Framework opens **"Built on one
  controller interface, a registry of parameterized actions and an event bus,
  this open-source Rust framework for SPM procedures makes a conditioning routine
  *reproducible, portable across hardware, shareable and extendable* rather than
  dependent on one operator's experience."** and stops there.
  The `Built on …` clause is the fix for a second piece of reviewer feedback: the
  sentence used to open cold on "An open-source Rust framework for writing SPM
  procedures, built so …", which asserted the four values before the reader knew
  what the thing was made of. The three items named are exactly the diagram's
  `Controller`, `Actions` and `Event bus` nodes, so the sentence now introduces
  the figure below it. If a node is renamed, rename it here too.
  The earlier closing line, "The loop above is one such script… Open source,
  linked from the QR code", was cut by the author. Do not bring back "The loop
  above" as an opener either; the `Built on …` clause does that job without
  reaching backwards into another panel.
  The `rustytip` citation was removed from the reference list
  for the same reason. This is deliberate and came from the author: the PI is not
  keen on the name, so the poster leans on what the thing *does* instead.
  The name is unavoidable in two places and both are fine, since they are
  pointers rather than branding: the QR URL `github.com/kronberger-droid/rusty-tip`
  and `cargo add rusty-tip` in the Outlook *Try it* block. The `@software{rustytip}`
  entry is still in `refs.bib`, just uncited, so it renders nowhere (only cited
  entries appear). Do not re-add the citation or a bold product name to Framework.
- **"The Conditioning Loop"** (was "Pulse & Check").
  The panel now carries the stability check, so the old title undersold it.
  **The intro is two sentences and must stay that way.** It used to end "When the
  stability test is enabled, the loop terminates only once the apex has passed
  it." That was cut on author feedback: the *Stability* bullet says the same
  thing three lines further down, and the conditional made a configuration
  detail sound like the headline. The cut is also what bought the left column its
  slack back, roughly 10 mm. Do not re-add a sentence about when the stability
  test runs; the bullet owns that.
- **"Beyond the Frequency Shift" is gone.** It was a short analysis chapter
  (structured logs, pure-function analysers, CuOx row detector, offline
  parameter optimisation) and every part of it belonged somewhere else:
  - *Every run is a record* -> Framework, merged with the old *Observable*
    bullet, which already half-said it via the `Event bus` node
  - *Analysers are pure functions* -> Framework, as *Analysers plug in*
  - *Parameters from the archive* -> Outlook, since offline optimisation is
    future work and Outlook is where future work goes
  - *CuOx row detector* -> one clause inside Outlook's *Functional terminations*
    bullet, which already named CuOx and cited the same paper
  The closing line ("A finished run stops being an anecdote and becomes the
  input to the next one") did not survive as a sentence, but its argument is now
  Motivation's *Long runs that log themselves* bullet. Do not re-add the panel;
  it duplicated Framework by the end.
- **The right column is four panels, one claim each.** It has been merged and
  split more than once, and the rule that settles it is *one claim per panel*:
  - **Δf as a proxy for imaging quality**: three STM scans, three apexes
  - **Proof of Concept**: the tip got sharp (intro, then the plot)
  - **The App**: the software you would actually operate
  - **Outlook**: future work, with the QR boxed into the last two bullets
  A GUI screenshot is not evidence that a tip was conditioned, so it never
  belonged under Proof of Concept. The tell, when they were merged, was that the
  screenshot paragraph had no bold lead-in and sat wedged between two figures,
  reading as a caption that had outgrown its figure.
  **The split costs ~30 mm** (one header at the reduced inset, plus insets and a
  gutter). It was paid for twice over by two structural changes made just before
  it, neither of which cost any content:
  1. the panel header inset, `0.8em` -> `0.55em`, ~5 mm per panel
  2. boxing the QR into the bottom-right of Outlook beside the last two bullets
     instead of giving it its own row, ~30 mm
  Right-column slack afterwards is 10 / 13 / 11 / 11 mm. **If space is ever
  needed again, those two levers are spent; the next one is content.**
- **`Δf as a proxy for imaging quality` leads with its title.** The panel used to
  open with a lead-in paragraph, and the title was already saying it. It now goes
  title -> three scans -> one conditions line at `0.85em` underneath. The
  captions carry only what *differs* between the scans (Δf and frame size);
  everything the three share (constant-current STM, sample bias, setpoint,
  temperature) is stated once below the row rather than three times across the
  captions. **"Separate sessions, not the conditioning runs below" stays in that
  line and is still load-bearing**, and note it says *below* now that the scans
  sit above Proof of Concept rather than under the plot.
- **Proof of Concept no longer explains its own plot.** "Each marker is one
  accepted Δf measurement on fresh surface" was cut: the x axis reads `Δf read`,
  and The Conditioning Routine's *Bias pulse and reposition* bullet already says
  the tip moves to a fresh site between reads. It was a figure caption living in
  a paragraph.
- **Proof of Concept has no bullet list at all any more.** It went in two steps.
  First *Session 1:* and *Session 2:* went, since they restated the start value,
  the end value and the pulse count, which are literally the axes of the plot
  directly above them. Then the remaining three (*Not monotonic*, *The strategy
  shows*, *Still sharp later*) went too, as commentary on a figure that already
  reads clearly on its own.
  Two facts were kept because the plot genuinely cannot show them:
  - **elapsed time**, *70 s* and *41 s*, folded into the opening sentence. This
    is the number that makes the automation claim, so keep it
  - **one sentence under the plot**: bad reads are absorbed rather than fatal,
    and a fresh approach that afternoon still read -0.7 to -1.3 Hz. The second
    half is the *only* trace of run `155910` on the poster, which is separate
    evidence from the two plotted runs, not a reading off the figure
  Everything else that used to be in those bullets is recoverable from
  `## Data` below. In particular the deleted *The strategy shows* bullet was the
  poster's only statement that pulses were -4.0 V throughout. Its removal is
  safe **because** it removed a claim, but do not now let a caption drift toward
  calling the plotted loop adaptive. See the caveats under `## Data`.
  The freed ~90 mm went into the image stubs, which is what let the screenshot
  grow from 64 mm to 112 mm.
- The Outlook's *functional terminations* and *STM without Δf* bullets used to
  depend on the analysis panel coming first. They now stand on Framework's
  *Analysers plug in* bullet instead, which is the only remaining setup for
  image recognition. Keep that bullet.
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
- **The backend is one node, not three.** It went three stacked boxes (Nanonis /
  Mock / Your SPM, one arrow each) -> three boxes inside a `fletcher` `enclose`
  group with a "pick one" label -> a single `*Hardware* / Nanonis · Mock · yours`
  node on the spine. Both earlier versions read as *three subsystems the
  controller talks to*, which is wrong: they are interchangeable implementations
  of the one interface and exactly one is live per run.
  Given up deliberately: "Mock / offline replay" (the point that you can develop
  with no instrument attached) and the **dashed** border that marked `Your SPM` as
  an invitation rather than a shipped driver. That invitation now lives only in
  the *One interface, any instrument* bullet, so do not delete that bullet.
  Sizing: the one wide node costs more width than the 3-row column did. At
  `spacing.x = 9mm` (down from 11.5) and `w: 42mm` it measures ~379 mm at
  `scale: 1.75`. At the original 11.5 mm spacing it was 418 mm, i.e. 35 mm over.
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
  layer is the obvious next step. Outlook picks it up in `*Recipes, then
  agents:*`. Keep the hint short and the commitment in Outlook, not the other way
  round.
- **Outlook is four bullets.** *Cross-lab validation* was cut by the author.
  *Procedures, then agents* became **`Scripts, then agents`**: the scripting layer
  is named there because it is future work, which is the same reason `script` was
  removed from Framework. *Learning from the archive* now targets **bias-pulse
  amplitude, polarity and timing** rather than thresholds and bounds, since the
  pulse parameters are the interesting thing to optimise.
- **Say "bias pulse", not "pulse", on first use in a panel.** The loop panel opens
  "It applies bias pulses…" and its first bullet is *Bias pulse and reposition*;
  Proof of Concept says "34 bias pulses" and Framework "a bias pulse while the tip
  is engaged". Later mentions in the same panel drop "bias", which is the normal
  define-once convention. The plot legend still reads "287 pulses, 37 min" because
  the axis beneath it says `pulse cycle` and widening the legend risks it
  overlapping data.
- **Outlook was compacted from seven bullets to five** to buy height for the
  right column, by merging two pairs that were each making one argument:
  - `*Parameters from the archive:*` + `*ML-guided pulsing:*` -> `*Learn from the
    archive:*` (both are "use the record to choose better parameters", one by
    hand and one by learning)
  - `*A recipe language:*` + `*Agents at the instrument:*` -> `*Recipes, then
    agents:*` (both are "the registry is already a scripting surface", the second
    just points it at a model instead of a person)
  Five bullets is the floor. The remaining five each make a distinct claim, so
  the next compaction has to cut an argument rather than merge two.

## The GUI screenshots contradict the loop panel

`assets/app_screenshot_controll.png` (1891x1001) and
`app_screenshot_config.png` (519x986) sit side by side in The App, control left,
configuration right, both scaled to the **same height** (114 mm) so their captions
share a baseline. Aspect ratios are 1.89 and 0.53, so equal height means widths of
~215 mm and ~60 mm. Sizing by width instead would make the config tab about 2.6x
taller than the panel can hold. Width caps the pair at ~156 mm (2.42 x height +
gutter under ~383 mm), but the panel's own height binds first, at 114 mm.

**The config tab is legible on the printed poster, and it disagrees with the
`*Stability:*` bullet in The Conditioning Loop.**

| field | loop panel says | screenshot shows |
| --- | --- | --- |
| allowed Δf change | **0.4 Hz** | **0.2 Hz** |
| bias sweep range | **0.2 -> 2.0 V** | **0.01 -> 2.0 V** |

The poster is the one that is right: `tip_prep_with_stability.toml` has
`stable_tip_allowed_change = 0.4` and `bias_range = [0.2, 2.0]`. The screenshot
was taken with a different parameter set. Everything else in it agrees: bias steps
1000, step period 200 ms, polarity mode Both, scan speed 5.0 nm/s, sharp bounds
-2.0 to 0.0 Hz (the plotted runs' band), and Pulse Method offering exactly
Fixed / Stepping / Linear.

**Fix by retaking the screenshot with the shipped config loaded**, not by editing
the bullet. Then the screenshot corroborates the bullet instead of contradicting
it, which is worth more than either alone. Until then this is the most likely
thing for a reviewer to catch on the whole poster.

Two more things visible in the control tab, both worth a decision:
- **"Simulation - no hardware connected"** in orange, with `Simulate` ticked. The
  screenshot is the **Mock** backend, not real hardware. Defensible, since the
  mock is a selling point, but it sits under a panel headed "Proof of Concept",
  so somebody will ask. Retaking it against hardware would remove the question.
- **"Tip preparation stopped by user"** in the last log line, at cycle 193 with
  `elapsed=605.0s`. That is independent corroboration of Proof of Concept's
  "most of them test runs cut short by hand rather than by the routine", which is
  a nice accident. Keep the two consistent if either changes.

## Sample naming, and the scans' provenance

- **The sample is oxygen-reconstructed Cu(110)**, the O-induced added-row
  reconstruction, conventionally `Cu(110)-(2x1)O`. `todo[sample system]` is closed.
- **Do not call the sample "CuOx".** On this poster **CuOx already means the tip
  termination**: Outlook cites Wiesener 2024, whose title is "Chemically Selective
  Imaging with a *CuOx-Terminated Tip*". Labelling the sample CuOx too makes it
  impossible to tell which end of the junction is oxidised and breaks that bullet.
  The descriptive form "oxygen-reconstructed Cu(110)" stays unambiguous.
- **The three STM scans are from independent sessions, NOT from the plotted runs.**
  They exist only to show what a frequency shift is a proxy for: the same surface
  imaged with a blunt and with a sharp apex. Because they sit directly under the
  convergence plot, the adjacency would otherwise imply they came from those two
  sessions, so the lead-in says "Separate sessions, not the runs above" and that
  clause is **load-bearing**. Their titles are `blunt apex` / `sharp apex`, not
  "conditioned apex", since nothing shows the routine produced them.
  **All three slots are filled with real scans**, all 512x512 crops with no
  colourbar, all at a **30 x 30 nm** frame. They are **110 mm** tall. Read out of
  the file metadata on 2026-07-31:

  | file | Δf | bias | current | acquired | what it shows |
  | --- | --- | --- | --- | --- | --- |
  | `Cu(110)_bad.png` | **-1.8 Hz** | **+1.0 V** | ~100 pA | ? | broad, blurred rows |
  | `Cu(110)_okay.png` | **-1.0 Hz** | **-0.5 V** | 105 pA | 2025-05-11, 354 s | narrower, better defined rows |
  | `Cu(110)_good.png` | **-0.6 Hz** | **-0.2 V** | 100 pA | 2026-01-22, 498 s | rows internally resolved |

  **The apex is NOT the only variable, and the poster must not claim it is.**
  The frame size is controlled and the current is effectively matched at
  100-105 pA, but the bias is not: **+1.0 V, -0.5 V and -0.2 V**, so the blunt
  scan is at the opposite polarity to the other two and at five times the
  magnitude of the sharpest. On Cu(110)-(2x1)O that means the row is partly
  comparing empty against filled states, and some of the apparent improvement is
  electronic rather than a tip difference. The two useful scans are also eight
  months apart. This is the same class of objection as the magnification one
  answered below, and it is *not* answered.
  What is on the poster: the per-caption parameters make the spread visible
  rather than hiding it, which is the honest minimum. What would close it is a
  matched-bias replacement for the blunt scan. Until then, **do not tighten the
  lead-in into a claim of a controlled comparison**, and expect the question in
  person.

  **The acquisition conditions live in the captions, one line per scan.** They
  were briefly a single shared sentence in the lead-in, on the reasoning that
  conditions common to all three should be stated once. That reasoning was wrong:
  the scans do not share a bias. Per-caption is what made the spread above
  visible at all.

  **Caption format: named quantities, no descriptive words.**
  `Δf = −1.8 Hz, 30 × 30 nm` over `V = +1.0 V, I = 100 pA`, not "blunt apex, ...".
  Two lines per caption, and **keep all three at the same line count** or the row
  reads as a layout bug. Use Unicode `−` and `×` in the plain-text parts.
  **Math must be wrapped in `bold(...)`**: the caption is set bold and math does
  not inherit that, so a bare `$Delta f$` renders a light symbol against heavy
  units. This is why the captions were plain text before the quantities were
  named.

  Quoting the frame in every caption is not decoration. An earlier trio was at
  visibly different magnifications, roughly 3.5, 3 and 1.5 rows across the frame,
  so part of the apparent sharpness was scan size rather than apex quality. With
  all three at 30 nm that objection is answered on the poster.

  **The three are NOT on a common z-scale, and one needs leveling.** All three
  PNGs span the full 16-bit range, so each was auto-scaled to its own min/max on
  export and the pm-to-grey mapping differs per image. Profiling *along* the rows
  (top to bottom, which averages the stripe structure out) isolates slow drift
  from real corrugation:

  | scan | drift along the scan direction |
  | --- | --- |
  | -1.8 Hz | 0.6% of its range |
  | -1.0 Hz | 0.8% |
  | **-0.6 Hz** | **18.8%** |

  So the best scan spends nearly a fifth of its dynamic range on a vertical
  gradient, which is why it looks washed out beside the other two. **The missing
  processing step is line-by-line leveling / plane subtraction** (Gwyddion's
  *Align rows*, or *Level -> Remove plane*) before export, then export all three
  with a fixed z-range.

  Do **not** try to fix this in post from the PNGs: the absolute z is already gone,
  so any normalization applied now invents a shared scale that does not exist.
  Note also that the panel's claim is about *lateral* resolution, whether the added
  rows are resolved, which z-scaling does not affect, and no z-range or colourbar
  is quoted anywhere. So the figure is not wrong as it stands, it is just less
  immediate than it should be: right now the -1.0 Hz middle panel has the
  strongest contrast, so at a glance the row reads blunt -> best -> washed out
  while the captions say the opposite.

  `Cu(110)_okay_good.png` is left in `assets/` but **no longer used**: it was
  dropped for being too good, since it resolved the rows about as well as the
  -0.6 Hz scan and gave no useful contrast.

## The stability check in the archive, and the plotted pair

**The plotted pair is now `20260129_124032` and `20260129_123152`**, both from one
afternoon, both +/-8 V pulses, both ~8 min. They replaced `135558` / `115639` on
author request, to get the `Sharp -> Stable` edge onto the panel:

| | `124032` | `123152` |
| --- | --- | --- |
| pulses to reach the band | 36 (6.1 min) | 24 (4.0 min) |
| pulses total | 36 | 35 |
| sharp bounds | (-6.0, 2.0) | (-6.0, 0.0) |
| tolerance | 4.0 Hz | 2.0 Hz |
| baseline -> post-sweep | -0.836 -> **-0.109** | -1.268 -> **-5.104** |
| verdict | **passed**, 0.727 Hz | **failed**, 3.836 Hz |
| after | run ends | max pulse, ten more cycles, never regains the band |

**Only 9 of the 69 runs ran a stability check that executed.** Another 12 have a
sweep configured whose Nanonis call failed ("Bias Sweep can't be started because
some settings are bad"), so *a sweep appearing in a log does not mean it ran*.
Check for a `TipState` result, not for the action. Of the 9, seven have 0-2
pulses and are stability tests rather than conditioning runs; `124032` and
`123152` are the only two that are both.

**No run anywhere in the archive fails a check and then passes one.** Counting
`Check tip stability` actions per file gives a maximum of **2**, which is one
check block run in both polarities, never two blocks. The recovery path fires in
`123152` and the run was stopped before it got back into the band. So a
fail-then-recover-then-pass trace does not exist yet, and the two-run pair is the
closest the data comes. If such a run is ever recorded it would replace both.

**The tolerance is in Hz even though the log prints a percent.** The action string
says "200.0% change allowed" and `runner.rs` reads
`stability.stable_tip_allowed_change` as Hz, so that is 2.0 Hz. Verified against
all four passing/failing verdicts. Do not quote a percentage anywhere.

**The verdict is not in the sweep record.** Each sweep logs its own `TipState`,
but that comes from a `CheckTipStability` action that no longer exists in
`rusty-tip`, and its `is_stable` flag disagrees with the loop's own behaviour
(`163859` logs `Blunt` on sweep 1 and the run then ends cleanly). Today's
`check_stability` takes the last `confirm_sharp` read as baseline, sweeps, takes
one more read, and compares `|final - baseline|` against the tolerance.
`extract_trace.py` recomputes it that way and it matches what the loop then did
in every case. Read the outcome off the loop's *behaviour*, never off the sweep's
`TipState`.

**The plotted runs' sweep parameters do not match the loop panel's source
config.** They sweep `2.0 -> 0.2 V`, 200 steps, 100 ms, tolerance 2.0/4.0 Hz;
`tip_prep_with_stability.toml` is `0.2 -> 2.0 V`, 1000 steps, 200 ms, 0.4 Hz.
This is harmless *only because* the loop panel quotes no numbers (see the section
below). If numbers ever go back into that panel they have to come from these two
runs.

## The loop panel states no numbers, on purpose

Every bound, threshold and count came out of The Conditioning Loop's bullets: the
sweep range, the 5 nm/s scan speed, the 0.4 Hz tolerance and the 3x confirmation
count. The panel now closes with "Every bound, threshold and count is a parameter
of the run, not a constant of the method."

Two reasons, and the second is the stronger one:
1. It is what the framework claims. Presenting these as fixed numbers contradicts
   *Actions as data* and the whole config-driven design.
2. **It dissolves a contradiction that was otherwise unavoidable.** The config
   screenshot in `The App` shows `Allowed Change 0.2 Hz` and
   `Bias Range 0.01 -> 2.0 V`, while the bullets quoted 0.4 Hz and 0.2 -> 2.0 V
   from `tip_prep_with_stability.toml`. Both were true of different sessions, and
   both were legible on the same printed sheet. With the numbers gone the
   screenshot is now the *only* place a specific value appears, which is honest:
   the panel describes the mechanism, the screenshot documents one run.

So **do not put numbers back into the loop panel** without either removing the
config screenshot or matching them to it. The shipped values are still recorded
under `## Where the numbers come from` if they are ever needed for a talk.

## What the code actually says

Read out of `~/Projects/rust/rusty-tip` on 2026-07-30, because two diagram
redesigns were proposed on intuitions that turned out to be half right.

- **The event bus does not belong to the controller.** `WorkflowExecutor` owns
  `registry`, `controller`, `events`, `store`, `shutdown`, `state`, `policy` as
  **siblings**, and `run_tip_prep(controller, events, shutdown, config, …)` takes
  the bus alongside the controller. Emission happens around *action execution*
  (`action_started` / `action_completed` / `action_failed` in the Do-step path of
  `executor.rs`). So `Actions --emits--> Event bus` is correct as drawn; hanging
  the bus off Controller would misdescribe the code.
  Concrete observers: `FileLogger`, `ChannelForwarder` (to the GUI),
  `ConsoleLogger`, `EventAccumulator`.
- **Routine and Actions are not the same thing, and the split is the poster's
  main claim.** 16 modules under `src/action/`, and `ActionRegistry` is
  `HashMap<String, ActionFactory>` plus descriptions and state resolvers. That
  registry *is* `*Actions as data:*`, and both Outlook bullets (`A recipe
  language`, `Agents at the instrument`) stand on it. Merging the two boxes would
  reduce the figure to "a script drives hardware", which is true of any lab
  script.
  **But:** `runner.rs` never touches the registry (grep: 0 hits). It constructs
  action structs directly in Rust. The registry serves the config-driven
  `WorkflowExecutor` path. So there are two execution paths and the poster only
  ever describes the framework one.
- **An action sees exactly three things.**
  `ActionContext { controller: &mut dyn SpmController, store: &mut DataStore, events: &dyn EventEmitter }`.
  The `Action` trait is `name()`, `description()`, `requires() -> Vec<Capability>`,
  `execute(ctx) -> ActionOutput`. `description()` is commented "for documentation
  and LLM context", which is the MCP outlook bullet already half-built.
- **There is a second guard the poster never mentions.** `requires()` returns
  capabilities (`Signals`, `Bias`, `ZController`, `PiezoPosition`, `Motor`,
  `Scanning`, `Oscilloscope`) and the execution layer checks them against
  `SpmController::capabilities()` *before* running. That is separate from the
  `MachineState` precondition check. *Safe by construction* currently only
  describes the latter.
- **The recipe language largely exists.** `Step` is a serde enum with `Do
  {action, params, store_as, label}`, `Sequence`, `If`, `Loop`, `SetVar`, `Wait`,
  and `Condition` with `Compare` / `InRange` / `And` / `Or` / `Not`. That is a
  declarative workflow DSL with conditionals and loops, deserialisable from
  config today. Outlook's `A recipe language` says such a layer **"would"** let a
  procedure be written and diffed. That is a Framework fact wearing an Outlook
  hat, and it undersells the work. Worth rewording before printing.

## Cross-panel consistency

These pairings were wrong at some point and were fixed. Re-check them after any
wording change:

- **"Run" means two things**, and both meanings are now inside Framework, which
  is where this can go wrong fastest. *Actions as data* means the run as
  **input** (a procedure is a list of parameters). *Every run is a record* means
  the run as **output** (the JSON log). Keep the two bullets' vocabulary apart:
  parameters/procedure for the input, record/log/replay for the output. The
  earlier version of this note warned about Motivation colliding with the old
  analysis panel; both of those texts are gone.
- **Motivation states the aim, Framework states the design.** Motivation says
  what should be true of tip preparation (unattended, functionalised, logged);
  Framework says what was built and why (the four values, then the mechanisms
  that deliver them). Motivation must not acquire a mechanism bullet, and
  Framework must not re-argue the aim.
- **Outlook is future work only.** *Cross-lab recipes* used to promise sharing,
  which Motivation and Framework already claim works today. It is now
  *Cross-lab validation* (run one recipe on different instruments, see what
  transfers), which is genuinely open.
- **Framework hints, Outlook commits, and they must not use the same words.**
  Framework's *Actions as data* says a procedure is a list of parameters and that
  a scripting layer is next. Outlook's *Recipes, then agents* says what that
  layer would buy. Both now contain the phrase "list of parameters", which is the
  closest these two have ever been to repeating each other. If either is
  reworded, pull them further apart, not closer.
- Diagram sizing: measure against the panel, do not eyeball. Panel inner width
  is **~383 mm**. Use `context { measure(...) }` on a wide scratch page to find
  the scale that fits. The FSM sat at `scale: 1.1` (276 mm, 72% of the panel)
  and looked lost, then at `1.47` (376 mm), where `1.5` measured 383.6 mm once
  the phase captions were added, i.e. 0.6 mm over. Both figures are called from
  `main.typ`, which is where the live numbers are: the FSM at **1.38** and the
  architecture diagram at **1.82**, the latter with `spacing` defaulting to
  `sx: 5mm, sy: 18mm` to pay for the wide single `Instrument` node (`w: 48mm`,
  376.7 mm measured). `sx` is the only cheap lever left there: the diagram has
  five spine nodes and so four gaps, and each mm of `sx` costs `4 × 1.82` = 7.3 mm
  of total width. `sx: 6mm` measures 384 mm and is already over.
  **Re-measure after any node text change**; both figures have been pushed over
  the edge by a label twice now.
- **The Δf figure is a scatter with a faint connecting line, and the line must
  stay faint.** The loop repositions and re-approaches between every read, so
  consecutive points are measurements at *different places on the sample*. A
  solid line draws a continuous trajectory of one quantity, which is not what
  happened; these are independent samples of the apex, ordered by cycle. It was
  a full-strength line first and looked more authoritative for exactly the wrong
  reason. It is now `trace-line()` in `convergence.typ`, 1pt at 72%
  transparency, which orders the reads for the eye without asserting a path.
  The line also bridges the reads `clean()` drops, so strengthening it would
  draw a segment straight through excluded territory.
  A column/bar chart is worse still: bars encode magnitude from a zero baseline,
  but the meaningful reference here is the sharp *band* at (-2, 0), not zero, so
  a good outcome would render as the shortest bar. 295 bars across a 361 mm axis
  is also a 1.2 mm comb. If a bar chart is ever wanted, the version that works is
  a two-bar summary of *cycles to reach the band* (9 vs 287), which is a
  different figure making a different point.
- **The Δf figure now colours the stability check.** `extract_trace.py` tags every
  read with a `phase`: `loop` (follows a bias pulse), `confirm` (no pulse since
  the previous read, which is exactly what `confirm_sharp` produces) and
  `post_sweep` (the read after the bias sweeps). `confirm` and `post_sweep`
  together are the check, and `convergence.typ` draws them as purple diamonds.
  Design points that are not obvious:
  - **Both runs' check reads are one series**, so the legend gains one entry
    rather than one per run. They sit at different read numbers and the faint
    line still ties each back to its own trace.
  - **Purple, not green.** Green is the sharp band, and drawing a *failed* check
    in the band's colour reads as a pass.
  - **The faint connecting line is its own marker-less series** covering all of a
    run's reads. Splitting a run into two marker series would otherwise break the
    line exactly where the check starts.
  - **The x axis is `Δf read`, not `pulse cycle`.** The confirmation reads take no
    pulse, so the two counts part company precisely where the check begins, which
    is the part of the figure the axis has to label honestly.
  - **`clean()` now drops only the ±76.2937 Hz rail.** The old `floor` (|Δf| < 0.5)
    and `deep-cut` (< -28 Hz) exclusions were facts about the 2025 runs and had to
    go: these runs' sharpest reads are -0.109 to -0.275 Hz, and `-0.109` is the
    post-sweep read that decided `124032`'s verdict, while `deep-cut` would have
    removed 33 of 83 reads. The rail stays out, and the giveaway is `std_dev`
    exactly 0.000.
- **`lq.diagram(width:)` is the axes width, not the figure width.** Axis labels,
  tick labels and padding add roughly 28 mm on top. `convergence.typ` used to
  declare `300mm * scale`, and `scale: 1.2` rendered 394 mm, overflowing the
  383 mm panel even though 300 × 1.2 = 360 looks safe on paper. It is now
  `350mm * scale` at `scale: 0.96` from `main.typ`. Always measure the whole
  figure, never reason from the `width:` argument.
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

**The QR points at a Zenodo DOI, not at GitHub**: `repo-url` is
`https://doi.org/10.5281/zenodo.20325230`, with `repo-short` the same string
without the scheme. This replaced `github.com/kronberger-droid/rusty-tip`, so the
note further up about the repo URL being one of the two sanctioned places the
project name appears now applies to the DOI instead. A DOI is also citable, which
a repo URL is not.

Verified with OpenCV's `QRCodeDetector`, which decoded the rendered PDF back to
the exact URL.
Note that `codetastic` emits a **version-7 symbol (43x43 modules)** for this
URL, well above the minimum version 4 a reference encoder picks, so the modules
are smaller than you would expect for the size. **It is now 46 mm**, down from
58 mm, to buy height for the right column, which puts it at ~1.07 mm per module.
That is still well clear of the ~0.4 mm print floor, but it is the smallest this
should get without a scan test on the printed proof. The three-line caption beside
it also became two lines (`*Try it:* <url>` on one line, `cargo add` on the next),
so the whole block costs ~46 mm of height instead of ~60 mm.

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

Those are the shipped config values, and **the plotted runs do not use them**:
`124032` and `123152` sweep `2.0 -> 0.2 V` in 200 steps of 100 ms with a 4.0 Hz
and a 2.0 Hz tolerance. Checked, and it is safe only because the loop panel
states no numbers. A poster that quotes one config and plots another is the kind
of thing a reviewer will catch, so if numbers go back into that panel, take them
from the plotted runs and not from this file.

## Data

The full archive is **`/run/media/kronberger/DATA/Tip Prep/Experiments/`**:
69 runs, 13 GB, flat directory, spanning 2025-12-12 to 2026-05-27. That is the
source of truth. Look there first, and mount the drive before assuming a run is
missing.

**The two plotted runs are `20260129_124032` and `20260129_123152`**, not the
December ones inventoried below; see the stability-check section above. The
December inventory is kept because it is still the history of how the figure got
here, not because anything on the poster comes from it any more.

`./experiments/` in this repo is gitignored and is now down to a single 30 KB
file, `tip_prep_20251212_115127.json`, which is **demo mode** (Δf reads `-0.0`).
The runs described below live on the drive, not here. The poster still builds
without them, since `figures/traces.json` is committed and is all Typst reads.

**File size tells you nothing about run length.** The bulk of every file is
`ExperimentData.signal_frames`, the full TCP capture attached to each pulse. The
largest file is 2.7 GB; a 120 MB one holds only 38 cycles. Use
`scripts/index_logs.py`, not `ls -S`.

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

**What is plotted now: `151951` (short) and `20251213_115639` (long).** `152232`
and `155910` are no longer on the poster. The full drive was indexed to pick the
long one, see `### Picking a run` below.

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
- Pulses in `151951` were **-4.0 V throughout, with a single -5.0 V** at cycle 6.
  That is barely any adaptation. **The long run `115639` is different**: it used
  ±4, ±5 and ±6 V, so stepping *and* polarity switching are genuinely in that
  trace. Keep the two apart. "The plot shows adaptation" is true of the long run
  and false of the short one.

- **RESOLVED: the two plotted runs now share an exit criterion.** They did not
  when `151951` (9 pulses, Dec 12) was the short trace: that run exits on its
  **first** in-band read at -1.29 Hz, with no confirmation, while `115639`
  requires four. Swapping in `135558` fixed it, which was a side benefit of
  wanting a mid-length run rather than the reason for the swap.
  Both plotted runs now exit only after **four consecutive** in-band reads with a
  `Safe reposition: move (3,3)` between each:
  - `135558`: sharp at reads 28-31 of 32, then withdraw
  - `115639`: sharp at 291-294 of 295, then withdraw. It also read in-band at
    cycle 14 and at 77-79 and **carried on both times**, because the next read on
    a fresh site came back blunt
  Both use the same sharp band `(-2.0, 0.0) Hz`, which is why they can share an
  axis. If either trace is ever swapped again, **check the exit criterion of the
  replacement**: Dec 12 runs do not confirm, Dec 13 and Dec 15 runs do.

- **The rejected in-band reads are suspiciously close to zero**, and are now
  **filtered out of the plot**: -0.013, -0.010, -0.020, -0.017 Hz, against
  -1.56 to -1.88 Hz for the four reads accepted at the end and -1.29 Hz for the
  short run's exit. A read of -0.01 Hz is not obviously a sharp tip, it looks
  more like the signal dropping out.
  `convergence.typ` drops any read with `|Δf| < 0.5 Hz`. **The threshold is a
  fact about the data, not a preference:** those four sit at 0.010 to 0.020 Hz
  and the next smallest magnitude anywhere in either plotted run is 1.559 Hz, a
  factor of ~78. Nothing real is anywhere near 0.5. Filtering happens at plot
  time, not in `traces.json`, so the extracted data stays a faithful copy of the
  log and the exclusion is visible in one place.
  Consequence: **the figure no longer evidences the confirmation step**, since
  the two in-band excursions were exactly those reads. The caption that explained
  them was removed with them. The confirmation claim now lives only in the loop
  panel's *Check* bullet, which is fine, that bullet cites the config not the
  plot. The evidence is still in the log if it is ever wanted back.

- **Two far-out reads are also dropped, and these ones are probably real.**
  -37.5 Hz at cycle 13 and -42.4 Hz at cycle 221, removed by `deep-cut = -28` in
  `convergence.typ`. Unlike the noise-floor four, nothing marks these as
  artefacts; they look like a genuinely very blunt apex. **They are excluded for
  readability alone**: they dragged the axis to -45 and squeezed 90% of the reads
  (-20.2 to -2.8 Hz) into 36% of the axis height. At `ylim: (-28, 2.5)` that same
  bulk gets 56%, and the lowest surviving read is -26.09 Hz so nothing is hidden
  just off-frame.
  Know that this is a presentation choice, not a data-quality one. If it ever
  needs defending, the two clean options are to put them back and clip the axis
  with off-scale markers at the edge, or to add "2 of 291 reads below -28 Hz
  omitted" to the caption. 289 reads remain.
- Legend sits `bottom + right`. Once the far-out reads are gone the last read
  below -20 Hz is at cycle 222, so everything past ~230 is empty and the box
  covers no data. It was briefly `bottom + center` when the axis still ran to
  -45. If the y range changes again, re-check what the box lands on.
- Is the `155910` tip the same tip as `152232`? Same afternoon, 35 min later, but
  nothing in the log proves it. `155910` is no longer cited on the poster (the
  "still sharp later" line went with the bullet list), so this only matters if
  it comes back.
- **The old note that "the December runs stop at the first in-band read" is now
  only half true**, and the loop panel's hedging was loosened accordingly. It
  held for the two Dec 12 runs that used to be plotted. `115639` shows the
  repositioned confirmation reads happening, so the confirmation *is* visible in
  the data now. `check_stability` is still off in all of these, so
  **gated on sharpness alone** in Proof of Concept remains load-bearing and must
  stay: confirmation is not the same thing as the bias-sweep stress test.

### Picking a run

All 69 runs were indexed with `scripts/index_logs.py` (100 s for the full 13 GB,
disk-bound). The cache is `scripts/runs_index.json`, so re-ranking is instant and
works with the drive unplugged. Note its `pulse_v` field **undercounts**: like
`extract_trace.py` did until 2026-07-30, it only matches `Pulse retract -4.0V`
and misses the 2026 wording `Bias pulse -8.000V`, which is why the index reports
0 pulses for `124032` (really 36) and `123152` (really 35). `scan_logs.py` and
`detail.py` count them correctly. Fix the regex in `index_logs.py` if the index
is ever used to rank by pulse count again.

```nu
python3 scripts/index_logs.py scan "/run/media/kronberger/DATA/Tip Prep/Experiments"
python3 scripts/index_logs.py report --min-pulses 10 --sharp-only
```

**±76.2937 Hz is a saturation rail, not a measurement.** It recurs in both signs
across many runs and sits within 3e-4 of `5e6 / 2^16 = 76.29394`, the signature of
a 16-bit full-scale artefact. Any read at that value is a clipped or invalid
sample. Demo-mode runs instead read `0.0` or `-8e-05`, i.e. the noise floor.

**14 files were deleted from the drive** (2026-07-30) because every read in them
was at the noise floor or the rail, so they contained no measurement at all: the
`0.00`/`-8e-05` demo runs `20251212_115127`, `20251213_112315`, `20251215_124706`,
`20251216_171849`, `20260126_125411`, `20260126_125450`, `20260126_130340`,
`20260126_130517`, `20260126_130822`, `20260126_131012`, `20260127_124001`,
`20260127_124208`, plus the single-read rail files `20260126_133822` and
`20260127_125029`. **83 runs became 69.** They freed no space, this was
decluttering. `scripts/runs_index.json` was pruned to match.

**Runs that merely *contain* rail reads were deliberately kept.** Deleting those
would have taken `20260128_145048`, the only run showing `Sharp -> Stable`, which
has 1 rail read among 19. If this comes up again, the rule is: delete a run only
when it has no valid read at all, and treat rail reads inside good runs as invalid
samples.

Still questionable and **not** deleted: `20260126_131226` (3 reads, +57.8 to
+67.4 Hz) and `20260126_134817` (+71.1 up to the rail). Sitting that near
saturation makes them look like clipped channels rather than real repulsive-regime
shifts, but that is a judgement about the instrument, not the file.

Genuinely positive reads elsewhere are small and unremarkable: `20251213_124835`
has 12 reads at +0.07 to +0.13 Hz, `20251213_135032` 4 at +0.17 to +0.18,
`20260129_115935` one at +0.18. The plotted long run has none (min -42.4, max
-0.01 before filtering).

Of the runs that actually reached the band:

| run | pulses | wall | Δf start -> end | note |
| --- | --- | --- | --- | --- |
| **`20251213_115639`** | **287** | **37 min** | **-13.4 -> -1.56** | plotted (long); ±4/±5/±6 V, confirmation visible |
| **`20251215_135558`** | **34** | **4.7 min** | **-7.6 -> -1.49** | plotted (mid); -2.0 to -6.0 V plus +3.9..+4.5, confirmation visible, 1 rail read at cycle 21 |
| `20251213_124835` | 339 | 44 min | -4.8 -> -1.58 | longest good run, but starts near the band so the story is weaker |
| `20260128_121504` | 184 | 29 min | -18.6 -> -13.9 | ends out of band, trace hits the `76.29` sentinel |
| `20251213_135032` | 105 | 14 min | -1.9 -> -1.81 | starts already sharp |

`20260128_093447` is the biggest file on the drive (2.7 GB, 779 pulses,
111 minutes) and is a **failure**: Δf goes -5.1 -> -38.1. Useful someday as an
"it can also not work" counterexample, useless for Proof of Concept.

`20260127_145314` is 1 GB and the indexer reports **0 entries**. It is not the
JSON-array format the parser expects, so it needs looking at before anyone
concludes it is empty.

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

## The `.typ` files carry no comments

The explanatory comments were stripped from all six `.typ` files on 2026-07-31
(1086 lines to ~500), leaving one header line each. Everything that justified a
number now lives here. **Do not write the explanations back into the source**;
add them to this file instead. What was only ever in a comment:

- **`par.spacing` is the recurring enemy, and it has now been beaten in four
  places.** Typst's default paragraph spacing is 1.2em, ~11.8 mm at `base-size`,
  and it falls between any two consecutive *blocks*, not just between paragraphs.
  Every one of these was an unrequested gap nobody chose:

  | where | now | what it cost before |
  | --- | --- | --- |
  | `panel`, header bar to first line of body | `above: 0.4em` | 16.9 mm measured, of which only ~4.9 mm was the inset. ~11 mm per panel |
  | `poster` header, title to author/logo row | `above: 0.8em` | the full 1.2em. Pays *both* columns, since the header sits above the `1fr` body row |
  | `figure-img`, image to its own caption | `stack(spacing:)` | a visible gulf that read as two unrelated elements |
  | figure rows under an intro paragraph | `above: 0.5em` / `1em` | ~7 mm each |

  The header one was briefly `0.35em`, which was too tight: the author row read
  as a third line of the title block. `0.8em` is the settled value.
- **`width: 100%` on those blocks is load-bearing**, everywhere. A bare `block()`
  shrinks to its content, so an `align(center, …)` inside it centres within a box
  already hard against the left inset, and the row silently goes left-aligned. In
  the poster header it would collapse the `1fr` author cell between the two logos.
- **The App's figure row uses `above: 1em`, not the `0.5em` the other rows use.**
  Its captions are *above* the images (`caption-above: true`), so the first thing
  under the intro paragraph is a line of bold text, and at 0.5em it read as a
  third line of that paragraph rather than as a label on the figure.
- **`panel-column`'s overfull check has 1pt of tolerance.** `measure` and the real
  layout disagree in the last fraction of a point, and a build that fails by
  0.3 mm helps nobody.
- **The page assembly is a full-page-height `block` wrapping the grid.** That is
  what gives the grid a known region, so the `1fr` body row can soak up whatever
  the header, contact strip and footer leave over. Row gutters are per-gap,
  `(0.4em, col-gutter, col-gutter)`: the contact strip hugs the header, and the
  body is then separated from contact and footer by the same 8 mm used between
  panels.
- **The architecture spine must sit on integer coordinates.** `fletcher`'s
  `spacing.x` is the *gap* between adjacent columns, so integers give equal gaps
  regardless of node width. The spine was once on 0 / 1.4 / 2.8 / 4.2 / 5.6, and
  a fractional step is a fraction of a column pitch set by the widest node, so the
  visible gaps came out uneven: wide after `Config`, tight before `Hardware`.
- **`Analyzers` are deliberately off the spine, because they are not `Action`s.**
  `Analyzer` is its own trait, `analyze(&AnalyzerInput) -> AnalyzerOutput`, with
  no `ActionContext` and no hardware. What runs one inside a routine is a separate
  adapter, `RunAnalyzer`, which *is* an `Action` wrapping an `Arc<dyn Analyzer>`:
  it pulls the frame `GrabScanFrame` left in the `DataStore` and writes the
  verdict back under the analyzer's name. That indirection is exactly why the same
  detector serves the live loop and an archived run, which is what Framework's
  *Pluggable analyzers* bullet claims. Drawing them as custom actions would delete
  the reason the claim is true.
- **The FSM's three phase captions must match the panel's bullet lead-ins
  verbatim.** They are the only thing tying the figure to the text. The bullets
  read *Bias pulse and reposition* / *Check* / *Stability*, and the captions are
  positioned to sit against the edges they annotate rather than in a row along the
  bottom, where they read as a detached caption strip.
- **The FSM's `Sharp -> Blunt` edge is the check rejecting a promotion**, not a
  failed sweep: a read landed in bounds and the repositioned re-read did not. It
  used to read "Δf drift", from when the panel carried a *Recover* bullet.
- **The Δf plot's `post-note` anchors are hand-placed, not computed.** The value
  is read from `traces.json` and follows the data; the anchor is a coordinate
  chosen in an empty region. With the rail reads dropped, x 36-41 is clear
  between -6 and -30 Hz, and x 26-32 is clear between -8 and -32. Re-check both
  if the plotted runs ever change.
- **The sharp band is drawn as two strips.** The runs' windows share their lower
  bound (-6.0) and differ at the top, 0.0 against 2.0, so drawing only the shared
  part would put `124032`'s +0.43 Hz read outside a band it was actually inside.
  The strip above 0 is drawn fainter, and both are one legend entry.
  Legend is `top + left` because both runs spend their first two thirds deep in
  the blunt region, leaving that corner empty. `ylim` is `(-78, 4)`.
- **The STM captions quote current as a magnitude on purpose.**
  `Current::Calibration` in the file metadata is itself negative (-500E-12 A/V),
  so the sign of `Current::Current` says more about the channel convention than
  about the tunnelling direction, which the bias already gives.
- **`Cu(110)_good.png`'s file comment reads "SensorJ after crashed to gypsum".**
  Worth knowing, and see the stamp warning below.

## The scan stamps disagree with the panel's lead-in

`figure-img` takes `stamp:`, which writes white text over the bottom-left of the
image itself. It must be placed inside a `box` wrapped tightly around `image()`:
`place` anchors to its enclosing block, and the enclosing block is
`align(center, …)`, which fills the whole grid cell. Anchoring to that would put
the stamp in the margin left of the image, since a scan at 110 mm is ~105 mm
inside a ~127 mm cell. `place` is out of flow, so a stamp adds no height and
cannot push a caption into the panel border.

The three stamps carry a date and the sample file name:

| scan | stamp |
| --- | --- |
| `Cu(110)_bad.png` | `24/01/04 · Cu(110)_00090` |
| `Cu(110)_okay.png` | `25/05/11 · CaSiO3/WO14.1/Cu(110)_00157` |
| `Cu(110)_good.png` | `26/01/22 · Gypsum_A12_0048` |

**The panel's lead-in says all three are "Three apexes on partially oxidised
Cu(110)", and two of the three stamps name something else.** The middle one is a
Cu(110) prepared under a CaSiO3/WO session, which is arguable; the third names a
gypsum sample outright, which matches that file's own "crashed to gypsum"
comment. Either the lead-in has to stop claiming one surface, or the stamps have
to be corrected, or the third scan has to be replaced. As it stands a reader who
reads both will not believe either.

Note also the date on the blunt scan, 24/01/04, is not in that file's metadata,
which had no acquisition date. It came from the author.

## Still open

Roughly in order of how much they cost the poster:

1. **No `todo[...]` marks are left.** The only hit for `todo[` in `main.typ` is
   the word inside the comment on line 7 that documents the helper. The STM
   acquisition parameters, the last ones open, came from the file metadata on
   2026-07-31. Grep before printing anyway.
   **The live risk on that panel is no longer a gap, it is the bias spread**: the
   three scans are at +1.0, -0.5 and -0.2 V. See the scans section above. That
   needs either a matched-bias replacement for the blunt scan or a lead-in that
   stops implying a controlled comparison.
3. **Stability-check data exists, and `Sharp -> Stable` is in it.** 25 of the 83
   runs carry `Check tip stability: bias sweep` actions; 16 returned a Nanonis
   `Error` ("Bias Sweep can't be started because some settings are bad"), so a
   sweep appearing in a log does not mean it ran. `scripts/index_logs.py` reports
   a pass/attempt ratio per run for exactly this reason.

   The one to look at is **`20260128_145048`**, which walks the whole FSM:

   ```
   Check tip state           -> Sharp     (-1.44 Hz, after a (3,3) reposition)
   bias sweep  0.20 -> 2.00V -> Stable    <- the edge the poster could not show
   bias sweep -2.00 -> -0.20V -> Blunt    <- second polarity moved the apex
   Pulse retract -8.0V ...               <- recovery, loop restarts
   ```

   **Do not put this on the poster as it stands.** Two parameter mismatches:
   - its sweep allows **100% change**, where the loop panel quotes `<= 0.4 Hz`
     from `tip_prep_with_stability.toml`. A `Stable` verdict at 100% tolerance is
     close to meaningless, so quoting this run under that bullet would misstate
     the criterion
   - its sharp bounds are **(-3.0, 0.0) Hz**, a third setting alongside the
     plotted runs' `(-2.0, 0.0)` and the config's `(-1.5, 0.0)`
   It also has only 1 pulse, so it is not a conditioning run at all.

   What it does prove is that the `Stable` state is reachable and that the
   recovery path fires when the second polarity moves the apex. To use it, either
   find a run whose sweep tolerance matches the quoted config, or requote the
   loop panel against this run's parameters.
4. Optional: a figure for Motivation. No room, and the panel is now two bullets
   of aim rather than the four-value list, so a cartoon would have to earn its
   space against Proof of Concept's images instead.

Both columns are near capacity. Adding anywhere means cutting somewhere in the
same column, and the right column no longer has the slack it had before the
screenshot panel.
