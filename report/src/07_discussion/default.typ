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

This chapter weighs the work as a whole: the architecture of @sec:framework against what it cost, the criterion of @sec:apex and the routine built on it against the evidence of @sec:validation, and both against the related work of @sec:conditioning.
It also marks where the results stop being trustworthy.

== Assessment of the architecture <sec:architecture-eval>

Whether the interfaces and boundaries of @sec:framework justify their cost must be judged against the shortcomings of @sec:poc-lessons and against what they delivered.
The deletions recorded there make the first case on their own.
For the second, three results of @sec:validation rest on the structure: every number in that chapter was computed from the run logs alone, across thirteen source revisions (@sec:events); the paths of @tab:coverage that no counted run took are tested all the same, through the mock backend; and a configuration change mid-run, a second routine and the classifier boundary (@sec:analyzers) arrived without changes to the routine's control flow.

The structure also opens three routes a script could not.
Guards can move into the harness as policy, refusing unsafe sequences before they reach the instrument; the limits file of the control server is a first piece (@sec:outlook).
The same server already gives an agent or a script read-only access to the instrument and to a run, so that data can be analysed in few steps and without risk to the tip.
And a routine written against the controller interface runs on another backend once one exists.
// The three routes and the judgement that a script would do for tip
// preparation alone: Martin, 2026-11-09. Limits file: rusty-tip
// src/control/limits.rs; read-only server: src/control/mod.rs:1-18.

Against that, the framework is large for what tip preparation alone needs: a fixed script with a minimal front end could condition a tip on this instrument.

That a routine is portable across instruments is, so far, a design intention, not a result.
The interface has two backends, the Nanonis backend and the mock, and the mock was written alongside the interface, so it shows that the interface can be implemented, not that it fits another vendor's model of an instrument.
Only a backend for a second controller can show whether the capability set has the right granularity and whether a routine runs unchanged elsewhere; @sec:outlook returns to it.

== Limitations of the criterion and the evidence <sec:limitations>

One scalar stands in for the state of an atomic-scale apex.
That it tracks image quality rests on operator experience; the three apexes of @sec:proxy-validation illustrate it, but they are no calibration.
The sharp window and the stability tolerance were set on one instrument and one surface.
Even there the choice is unsettled: the runs used four lower bounds of the window between $-1.0$ and $-2.0$ Hz (@tab:run-params).
What would need re-establishing on another instrument or surface is an open question.

The parameters were varied as the work went along, not in a designed comparison.
The data therefore show that the routine reaches a confirmed sharp tip under a range of settings, not that one strategy, voltage or window does so faster than another.

The measurement gates have a blind spot.
They judge how a batch varies, not where it lies.
A frequency shift beyond the PLL controller's range reads as a constant value at its limit, and all 494 readings at that limit passed both measurement gates (@fig:readings).
A railed reading lies outside every interval the linear strategy maps, so it draws the maximum voltage.
That pulse fires where the tip may be in contact with the surface.
The 290 readings that failed the measurement gates on every retry were used anyway, by design (@sec:measurement).
This trades a stalled run for a decision on a doubtful number.
A guard against the first case is planned but not yet built.

Several parts of the routine rest on little or no evidence from the instrument (@sec:mock-results).
The one stability test was judged against a tolerance of $1.0$ Hz, where the default is $0.2$ Hz.
The runs also span thirteen revisions of a development line.
Every run is traceable through the revision its log records, but the runs were not all made on the same code.

The criterion itself received less attention than the framework.
Development time went into the harness, the client and the log rather than into the question of how to judge the tip.
Operators assess a tip in real time from a few scan lines and their profiles, a classifier over a rolling window of scan lines has identified the tip state from a small fraction of an image @gordon2020, and more recent architectures could probably judge single lines with a confidence score.
The routine decides on one scalar threshold instead; @sec:comparison sets this against the related work and @sec:outlook returns to it.
// Where the time went, and that newer architectures could judge single lines
// with a confidence score: Martin, 2026-11-09. gordon2020: abstract and
// introduction (operators judge from a few scan lines and line profiles;
// rolling window of scanlines plus a temporal network, "little-to-no
// performance penalty").

== Comparison with related work <sec:comparison>

Against that background, the approaches of @sec:conditioning differ in two things: what judges the tip and what the method is bound to.
A standardized procedure such as mechanical annealing @tewari2017 needs no learned criterion, but runs as a script for one controller on a gold sample at liquid-helium temperature.
Learned criteria @rashidi2018 @krull2020 @wang2021 judge tips well on the surface they were trained on.
The labelled data each new surface needs make them costly @barker2024.
Template matching removes the training but still needs an image and prior knowledge of how the surface looks @barker2024.
Auto-CO-AFM is tied to one vendor's control software @alldritt2022.

Scanbot is the closest relative @ceddia2024.
It is open source and runs on any STM controlled by the Nanonis V5 software, not on one installation.
It also exposes hooks for the laboratory-specific parts, the same transferability this work argues for.
It differs in what it judges, an imprint scan rather than a $Delta f$ reading (@sec:conditioning), and in the record it leaves: this work adds typed contracts at the instrument boundary (@sec:interface) and a log from which each run can be reconstructed (@sec:events).

In return, this work asks that the routine be written down once and its window calibrated for the surface at hand (@sec:limitations).
It is bound to one vendor, as Scanbot is, until the backend for a second controller of @sec:architecture-eval exists.
But the binding sits in a backend behind an interface, not in the routine itself.
