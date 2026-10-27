#import "/report.typ": flex-caption
#import "/lib.typ": todo

// Run statistics: every tip_prep_*.jsonl in
// /run/media/kronberger/DATA/Tip Prep/Experiments/ from 2026-09-15 to
// 2026-10-06 whose run_finished outcome is `completed` or
// `stopped_by_user` (106 logs). Logs ending in an error, and the 2026-09-14
// logs without a run_finished record, are commissioning and not counted.
// Rail figures: data_collected events labelled `stable_read`, |value| > 76 Hz.
// Proxy images and their parameters: poster/main.typ, panel "Δf as a proxy".

= Results <sec:validation>

The routine ran on a Nanonis-controlled STM/nc-AFM with a qPlus sensor
@nanonis, on partially oxidized Cu(110), from 15 September to 6 October 2026.
All runs used the rusty-tip 0.5 development line (@sec:framework), thirteen
source revisions in all, each recorded in its log. The count covers the 106 runs
that completed or were stopped by the operator, not those that ended in an
instrument error during commissioning. This chapter reports what
was observed; @sec:discussion interprets it.

== Frequency shift as a quality proxy <sec:proxy-validation>

The routine's results are worth only as much as the number it optimizes.
@fig:proxy shows constant-current images of partially oxidized Cu(110) taken
with three apexes on three separate days, independent of the conditioning runs.
Ordered by the apex's frequency shift, from $-1.8$ Hz to $-0.6$ Hz, they are the
evidence that $Delta f$ tracks the images an operator would judge by. Three
apexes make this evidence qualitative, not a calibration.
#todo[One sentence on what changes across the three images: which features
  the $-0.6$ Hz apex resolves that the $-1.8$ Hz one does not.]

#figure(
  grid(
    columns: 3,
    column-gutter: 2mm,
    image("fig_cu110_bad.png"), image("fig_cu110_okay.png"), image("fig_cu110_good.png"),
    [(a) $Delta f = -1.8$ Hz], [(b) $Delta f = -1.0$ Hz], [(c) $Delta f = -0.6$ Hz],
  ),
  caption: flex-caption([
    Constant-current STM images of partially oxidized Cu(110), $30 times 30$ nm,
    taken with three apexes on three separate days. (a) $+1.0$ V, $100$ pA;
    (b) $-0.5$ V, $105$ pA; (c) $-0.2$ V, $100$ pA. The frequency shift is
    that of the apex in each image.
  ], [STM images of partially oxidized Cu(110) taken with three apexes]),
) <fig:proxy>

== Unattended conditioning runs <sec:hardware-results>

Of the 106 runs, 53 completed with a confirmed sharp tip and 53 were stopped by
the operator to change parameters. Until the live configuration reload of
@sec:events was available, a different window or pulse strategy meant stopping
and restarting the run. The reload was used in one run. Twelve completed runs
met an already sharp tip and confirmed it without a pulse.

The other 41 completed runs needed 1 to 228 pulses (median 11) and $0.6$ to
$34$ min (median $2.4$ min). Their first readings spanned the frequency-shift
range from one limit to the other, with a median of $-4.0$ Hz. @fig:run shows a
typical course. For 46 pulses, $Delta f$ scatters between a few hertz and the
edge of the range, with no trend towards the window. Then a single pulse lands
the tip inside it, and all three confirmation readings hold.

#figure(
  image("fig_run.pdf", width: 85%),
  caption: flex-caption([
    Run of 25 September 2026, with $plus.minus 8$ V pulses whose polarity
    reverses on every third pulse, and a sharp window from $-1.5$ to $0$ Hz.
    Top: frequency shift after each pulse, on an axis that is linear within
    $plus.minus 1$ Hz and logarithmic beyond. Bottom: the pulse that followed
    each reading. The tip reached the window after 47 pulses and $6.4$ min.
  ], [A conditioning run of 25 September 2026]),
) <fig:run>

The confirmation readings rejected tips that had reached the window. In 14 of
the 53 completed runs, at least one reading inside the window failed to hold at
the next sites. This happened 25 times in total and up to four times in one
run. Each time, the routine resumed pulsing and later confirmed a tip.

The runs covered a range of parameters (@tab:run-params); the stepping strategy
was not used. The stability test was enabled in four runs and ran in one, on a
tip sharp from the start. Its reading went from a baseline of $-1.26$ Hz to
$-1.19$ Hz. This change of $0.07$ Hz lay within a tolerance of $1.0$ Hz, and the
tip was classified stable. With no failed stability test, the maximum-voltage
pulse of @sec:criteria-applied never fired on the instrument.

#figure(
  table(
    columns: 3,
    align: (left, left, right),
    table.header[Parameter][Value][Runs],
    table.cell(rowspan: 4)[Sharp window, lower bound],
    [$-1.0$ Hz], [3],
    [$-1.2$ Hz], [16],
    [$-1.5$ Hz], [74],
    [$-2.0$ Hz], [13],
    table.cell(rowspan: 2)[Pulse strategy],
    [fixed, $5$ to $8$ V], [39],
    [linear, between $2$ and $9$ V], [67],
    table.cell(rowspan: 2)[Polarity reversed every $n$-th pulse],
    [$n = 3$, $5$ or $6$], [44],
    [$n = 10$], [61],
    [Stability test enabled], [], [4],
  ),
  caption: flex-caption([
    Parameters of the 106 counted runs. The upper bound of the window was
    $0$ Hz throughout; one run used no polarity reversal.
  ], [Parameters of the counted runs]),
) <tab:run-params>

Not every accepted reading was a measurement. Of 4430 accepted readings, 520
($11.7 %$) sat at $plus.minus 76.29$ Hz. This is most likely the limit of the
PLL's frequency range, where the PLL has lost lock. Of these readings, 509
passed both gates of @sec:measurement. A further 290 readings failed the gates
on every retry and were used anyway.
// 76.29 Hz = 5 MHz / 2^16; "most likely the PLL range" is the hedge from the
// 2026-10-07 handover note, which also traces most rail reads to landings.

== Verification against the mock backend <sec:mock-results>

The mock backend of @sec:controller-trait exercised paths that are hard or
unwise to provoke on the instrument. The routine's tests run it to each ending:
a tip already sharp, with and without the stability test; a tip that sharpens
after a number of pulses; a tip that stays blunt until the cycle limit; and a
sharp but unstable tip that draws the maximum-voltage pulse. Further tests stop
a run during the first approach and before the loop, inject an I/O fault mid-run
and a fault during cleanup, send a new configuration mid-run, and let a routine
panic. Each test checks that the tip ends withdrawn and that the run reports the
right outcome.

Both protocol boundaries were tested against real servers, not stubs. The
Nanonis client of @sec:interface ran against the vendor's simulator as well as
the instrument. Without either, its tests cover encoding and decoding of every
data type and the typed parameter sets of its larger subsystems. The classifier transport of @sec:analyzers is tested against an
HTTP server on a local socket. This test checks that an unreachable model and a
wrongly answering model surface as different errors.

Evidence from the instrument therefore covers the pulse loop with the fixed and
linear strategies, the confirmation readings, the endings by completion and
operator stop, and the cleanup after them. The stability test and the live
configuration reload have one run each. The stepping strategy, the
maximum-voltage pulse after a failed stability test, the cleanup after a panic
and the classifier have been exercised only against the mock.
