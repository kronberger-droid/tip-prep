#import "/lib.typ": todo

// Sources: chapters 4 to 6 of this report and the code and logs behind them;
// rusty-tip CHANGELOG.md (0.2.3 released 2026-05-27); the run archive on the
// DATA drive (no hardware runs between 2026-05-27 and 2026-09-14). Related
// work checked against the papers in Zotero: tewari2017 (mechanical
// annealing, custom MATLAB on an RHK R9, Au at 2 to 4.2 K), rashidi2018 (CNN
// trained on H:Si dangling bonds, 97 %, >99 % with majority voting),
// alldritt2022 (Auto-CO-AFM, pre-trained library, requires CreaTec STMAFM),
// ceddia2024 (Scanbot, Nanonis V5, hooks), barker2024, krull2020, wang2021.

= Discussion <sec:discussion>

What the results mean, and where they stop being trustworthy.

== Assessment of the architecture <sec:architecture-eval>

Whether the seams of @sec:framework paid for themselves must be judged against
the failures of @sec:poc-lessons. The deletions recorded there make that case on
their own. So does the classifier boundary, which admitted a new kind of
decision-maker, still untried (@sec:analyzers), without changes to the routine
or the control path. A second, unrelated routine, the drift measurement of
@sec:harness, runs on the same harness and serves two front ends from one
implementation.

Against that, the abstraction cost instrument time. The rewrite around the
harness and the controller interface took the routine off the instrument. The
last release ran there on 27 May 2026, and the next run followed on 14
September, on the development line. The routine's thresholds, calibrated against
the earlier code path, had to be re-established on the instrument. For a project
of this length, three and a half months without the instrument is a large share
of the time.

That the structure makes a routine portable across instruments is, so far, a
design intention, not a result. The controller interface has two backends: the
Nanonis backend and the mock. The mock was written alongside the interface, so
it shows that the interface can be implemented, not that it fits another
vendor's model of an instrument. Only a backend for a second controller can show
whether the capability set has the right granularity and whether a routine
written against it runs unchanged elsewhere. That backend is the minimum for
calling the interface general, and @sec:outlook returns to it.

== Limitations of the criterion and the evidence <sec:limitations>

One scalar stands in for the state of an atomic-scale apex. The evidence that it
tracks image quality rests on three apexes (@sec:proxy-validation) and is
qualitative, not a calibration. The sharp window and the stability tolerance
were set on one instrument and one surface. Even there the choice is unsettled:
the runs used four lower bounds of the window between $-1.0$ and $-2.0$ Hz
(@tab:run-params). What would need re-establishing on another instrument or
surface is an open question.

The parameters were varied as the work went along, not in a designed
comparison. The data therefore show that the routine reaches a confirmed sharp
tip under a range of settings, not that one strategy, voltage or window does so
faster than another.

The measurement gates have a blind spot. They judge how a batch varies, not
where it lies. A frequency shift beyond the PLL controller's range reads as a
constant value at its limit, and all 494 readings at that limit passed both
measurement gates (@fig:readings). A railed reading lies outside every interval
the linear strategy maps, so it draws the maximum voltage. That pulse fires
where the tip may be in contact with the surface. The 290 readings that failed
the measurement gates on every retry were used anyway, by design
(@sec:measurement). This trades a stalled run for a decision on a doubtful
number. @sec:outlook describes the
guard planned against the first case.

Several parts of the routine rest on little or no evidence from the instrument
(@sec:mock-results). The one stability test was judged against a tolerance of
$1.0$ Hz, where the default is $0.2$ Hz. The runs also span thirteen revisions
of a development line. Every run is traceable through the revision its
log records, but the runs were not all made on the same code.

== Comparison with related work <sec:comparison>

The approaches of @sec:conditioning differ in what judges the tip and in what
the method is bound to. A standardized procedure such as mechanical
annealing @tewari2017 needs no learned criterion, but runs as a script for one
controller on a gold sample at liquid-helium temperature. Learned criteria
@rashidi2018 @krull2020 @wang2021 judge tips well on the surface they were
trained on. The labelled data each new surface needs make them costly
@barker2024. Template matching removes the training but still needs an image
and prior knowledge of how the surface looks @barker2024. Auto-CO-AFM is tied
to one vendor's control software @alldritt2022.

Scanbot is the closest relative @ceddia2024. It is open source and runs on any
STM controlled by the Nanonis V5 software, not on one installation. It also
exposes hooks for the laboratory-specific parts, the same transferability this
work argues for. It differs in what it judges, an imprint scan rather than a
$Delta f$ reading (@sec:conditioning), and in the record it leaves: this work
adds typed contracts at the instrument boundary (@sec:interface) and a log from
which each run can be reconstructed (@sec:events).

In return, this work asks that somebody write the routine down once and
calibrate its window for the surface at hand (@sec:limitations). It is bound to
one vendor, as Scanbot is, until the backend for a second controller of
@sec:architecture-eval exists. But the binding sits in a backend behind an
interface, not in the routine itself.
