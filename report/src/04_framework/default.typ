#import "/report.typ": flex-caption
#import "/lib.typ": todo
#import "fig_architecture.typ": architecture-diagram

// Describes the rusty-tip 0.5 development line as main plus the
// feat/frame-classifier stack (PRs #12 to #17), written as if that stack
// were rebased onto main. Typed `Frame`, the removal of `DataStore`
// (8752ef5) and `src/classifier/` exist only on that branch so far.
// Sources: src/routine/mod.rs, src/routine/rt.rs, src/session.rs,
// src/action/mod.rs, src/spm_controller.rs, src/mock_controller.rs,
// src/event/, src/experiment_log/, docs/experiment-log.md, CHANGELOG.md
// [Unreleased]; on the branch src/frame.rs and src/classifier/.

= The automation framework <sec:framework>

The framework is the general foundation a routine runs on; the routine itself is
@sec:routine. Separating the two makes a routine reproducible, shareable and
extendable, rather than a script bound to one instrument. The separation is
also designed to make it portable across instruments, and
@sec:architecture-eval tests how far that holds. @fig:architecture shows the
parts and how a routine reaches the instrument through them.

#figure(
  architecture-diagram(),
  caption: flex-caption([
    Structure of the framework. A routine owns the control flow and reaches
    the instrument only through capability-checked handles; every operation
    on the way is reported to the event bus.
  ], [Structure of the framework]),
) <fig:architecture>

Its shape follows from what earlier versions got wrong, so the chapter starts
there.

== Precursor implementations <sec:poc-lessons>

Three earlier structures were deleted. Each deletion is evidence the rest of
the chapter answers to.

Routines were data. A declarative engine with its own steps, loops and
conditionals sequenced actions, each constructed by name from a registry. It
worked, but was removed for reinventing a general-purpose language badly inside
a configuration file. The registry went with it, since constructing an
operation from a string existed only to read those step lists. @sec:harness
replaced it with control flow in Rust, where the compiler can see it. What
might yet replace *that* at a better layer is the scripting question of
@sec:outlook.

The engine also needed a machine-state model, since a step list read from a
file has no compiler behind it. The model decided at run time whether a step
was legal before executing it. A routine written against the harness cannot
pose the question (@sec:harness), so the state model was deleted with the
engine and the registry. The change removed 2894 lines and added 10; the
tip-preparation end-to-end tests passed unchanged.

Measurements went into a shared store as JSON under string keys, and whoever
needed them read them back. That made every consumer a parser and every schema
change a silent breakage. Its last writer handed grabbed scan frames to the
analyzers. Once frames became a typed value (@sec:controller-trait), the store
had no job left. A structure that disappears once the types are right was never
carrying the design.

The line drawn afterwards is that a configuration file owns a run's numbers,
not its control flow. The reproducible artifact the abstract promises is then
the run's log, which embeds its configuration (@sec:events).

== Hardware abstraction <sec:controller-trait>

A routine targets one interface to the instrument, the `SpmController` trait,
not a TCP protocol. Each implementation of the trait, a backend, reports its
capabilities, such as bias control, the Z-controller, the coarse motors,
scanning, the phase-locked loop (PLL) or a data stream. An operation that needs
a missing capability fails with an `Unsupported` error before any command
reaches the instrument. A routine therefore refuses cleanly on an instrument
that cannot run it. The Nanonis client of @sec:interface is the only hardware
backend today. The trait is the seam for adding others.

Results are typed too. A grabbed scan image is a `Frame`, not the JSON blob of
@sec:poc-lessons. It carries its pixels, channel, dimensions and scan
direction, plus the physical geometry the instrument reports (centre, size,
rotation). A frame loaded from a file carries no geometry, and a consumer can
tell the difference.

A mock backend implements the same trait without an instrument. Its frequency
shift follows a scriptable model of the tip's response to pulses. Faults can be
injected on chosen calls, and every call is recorded for inspection. A seeded
random generator makes a simulated run repeatable. Its Z-controller is simulated
too. Routines are developed and tested against the mock;
@sec:mock-results reports what that covers.

== Routine harness <sec:harness>

A routine is a plain Rust struct implementing the `Routine` trait. Its `run`
method receives a runtime, `Rt`. The runtime absorbs the scaffolding every
routine would otherwise reimplement, so the body contains only the science:

- *Subsystem handles.* `rt.bias()`, `rt.z()`, `rt.scan()` and their siblings
  check the backend's capabilities when obtained and report every operation
  through them to the event bus.
- *Cancellation.* Waits are interruptible, and a stop request surfaces as the
  outcome "stopped by the operator", not as an error.
- *Budgets.* A cycle driver turns cycle and time limits into outcomes instead
  of hand-written checks.
- *Cleanup.* `rt.guarded` pairs a body with a cleanup that runs however the
  body ends, restoring hardware such as a running scan or a changed scan speed.

Around the routine, the harness owns the run. It prepares the backend and sets
what the routine declares it needs (for tip preparation, the Z home position
and the safe-tip protection). It then runs the routine. Whatever the outcome,
it leaves the tip as the routine's exit policy says, restores the protection
and tears down. That includes a panic. A guard around the routine catches the
unwinding, cleans up the hardware and re-raises the panic unchanged.

Safety follows from the structure, not from the operator's discipline. With the
machine-state model of @sec:poc-lessons deleted, it no longer rests on run-time
bookkeeping. The handle is the only route to an operation, and obtaining one
runs the capability check. A call the backend cannot serve therefore cannot be
written: the compiler enforces what the state model checked at run time. What
remains at run time are checks only a live reading can answer, such as the
landing gate of @sec:outcomes.

The harness borrows the backend instead of consuming it, so one connection can
run routine after routine. A session builds on this. It connects once, loads
the instrument's layout and settings and starts the data stream. It then runs
jobs one at a time, each with its own log. Tip preparation is the reference
routine, not the only one: measuring and compensating the Z-piezo drift is a
second routine on the same harness, shared by the graphical interface and the
`const-distance` command-line tool.

== Event system <sec:events>

Every operation through a handle is reported to an event bus when it starts,
completes or fails, with its parameters, duration and result. Routines add
their own typed events. Tip preparation reports each cycle, phase change and
maximum-voltage pulse. Observers subscribe to the bus: one writes the run to a
log file, one prints to the console, one forwards events to the graphical
interface. One bus thus serves live monitoring, logging and offline analysis,
instead of logging bolted on afterwards.

The log describes itself. It opens with the tool, its version and source
revision, the loaded configuration with every default applied, the resolved
signals and stream rate, and a schema for every event type the tool can write.
It closes with the outcome. Every entry carries a sequence number, and every
operation a nesting depth. The steps inside a compound operation such as a
calibrated approach can thus be reassembled into a tree. A configuration change
during tip preparation takes effect between cycles, except for fields frozen at
run start. The log records each change with the full resulting configuration.
The log alone therefore suffices to reconstruct what was run and with which
numbers.

The front ends build on the log. Tip preparation runs from a command-line tool
or as a tool of a graphical workbench (@fig:workbench). Its setup there is a
form generated from the configuration's schema, and its run view shows the tip
state, the $Delta f$ trace against the sharp window and the pulse voltages.
The view is a fold over the run's log records, so a live run and a log
reopened from the tool's history share one code path. A terminal reader lists,
inspects and exports archived logs.
// rusty-tip bin/rusty-tip-gui/tools/tip_prep.rs:1-7 (setup form, run panel),
// run_view.rs:1-6 (the fold, tested equal live and replayed at :381),
// app.rs:104 (History per tool); bin/tip-prep, bin/rt-log.

// PLACEHOLDER: replace the box with the screenshot of Tip prep -> Run.
#figure(
  rect(
    width: 100%,
    height: 55mm,
    stroke: (paint: luma(160), dash: "dashed"),
    align(center + horizon, text(fill: luma(110))[
      Screenshot: workbench, Tip prep tool, Run tab
    ]),
  ),
  caption: flex-caption([
    The tip-preparation tool of the workbench during a run: tip state,
    frequency shift against the sharp window, and the pulse voltages.
  ], [The tip-preparation tool of the workbench]),
) <fig:workbench>

== Analyzers and classifiers <sec:analyzers>

// Classifiers generalize what analyzers do; expect analyzers to fold in.

The framework has two ways to turn a measurement into a decision. An analyzer
is a pure function over a frame, so the same code runs live, over archived data
and in a test. A classifier is a model, reached over a boundary of pixels as an
npy array and metadata as JSON, since models are written in Python and the
control path is not. An unreachable model and one that answers wrongly are
distinct errors, since only the first justifies falling back to a simpler
criterion. Model, version, latency and verdict enter the log like any other
decision. The classifier side is infrastructure so far: no trained model is
attached, and tip preparation decides on thresholds of $Delta f$
(@sec:criteria-applied) without consulting either kind.
