#import "/report.typ": flex-caption
#import "/lib.typ": code, todo
#import "fig_architecture.typ": architecture-diagram

// Describes the rusty-tip 0.5 development line as main plus the
// feat/frame-classifier stack (PRs #12 to #17), written as if that stack
// were rebased onto main. The removal of `DataStore` (8752ef5) and
// `src/classifier/` exist only on that branch so far. Names set with
// `#code(..)` link to the revision pinned in data/code_refs.json and are
// listed in @tab:code.
// Sources: src/routine/mod.rs, src/routine/rt.rs, src/session.rs,
// src/action/mod.rs, src/spm_controller.rs, src/mock_controller.rs,
// src/event/, src/experiment_log/, docs/experiment-log.md, CHANGELOG.md
// [Unreleased]; on the branch src/frame.rs and src/classifier/.

= The automation framework <sec:framework>

The framework is the general foundation a routine runs on; the routine itself is the subject of @sec:routine.
Separating the two is meant to make a routine reproducible, shareable, extendable and portable across instruments; @sec:architecture-eval assesses how far that holds.
@fig:architecture shows the parts and how a routine reaches the instrument through them.
@tab:code lists where each of them is declared in the code.

#figure(
  architecture-diagram(),
  caption: flex-caption(
    [
      Structure of the framework.
      The harness runs a routine, which owns the control flow and reaches the controller interface only through subsystem handles that check the backend's capabilities.
      Routine and handles report to the event bus.
      Dark: hardware; dashed: not used by tip preparation.
    ],
    [Structure of the framework],
  ),
) <fig:architecture>

The framework's structure follows from the shortcomings of earlier versions, so the chapter starts with them.

== Precursor implementations <sec:poc-lessons>

Three earlier structures were deleted, and each deletion fixed a requirement that the rest of the chapter meets.

Routines were data: a declarative engine with its own steps, loops and conditionals sequenced actions that a registry constructed by name.
It worked, but it amounted to a poor reimplementation of a general-purpose language inside a configuration file, and @sec:harness replaced it with control flow in Rust, where the compiler can see it.
Because a step list read from a file has no compiler behind it, the engine also carried a machine-state model, which tracked the instrument's state and decided at run time whether a step was legal.
Engine, registry and state model were deleted together.
The question the model answered remains: a routine's author now answers it in the control flow, and a caller with no compiler behind it would need the model again (@sec:outlook).
// What the model tracked (tip engagement, bias, Z-setpoint, Z-controller
// status, scan activity, safe-tip) and that actions declared requirements
// against it: rusty-tip src/machine_state.rs before its deletion in f76a991.

Measurements went into a shared store as JSON under string keys, which made every consumer a parser and every schema change a silent breakage.
Once grabbed scan frames, the last thing written to it, became a typed value, the store had no job left.

The resulting rule is that a configuration file holds a run's parameters, not its control flow.
The reproducible artifact this report's abstract promises is then twofold: the run's log, which embeds its configuration (@sec:events), and the routine itself, which is written against the controller interface and not against one instrument (@sec:controller-interface).

== Hardware abstraction <sec:controller-interface>

A routine targets one interface to the instrument, the controller interface #code("SpmController"), not a TCP protocol.
Each implementation of the interface, a backend, reports its capabilities, such as bias control, the Z-controller, the coarse motors, scanning, the phase-locked loop (PLL) or a data stream.
An operation that needs a missing capability fails with an #code("SpmError::Unsupported")[`Unsupported`] error before any command reaches the instrument.
A routine therefore fails with a clear error on an instrument that cannot run it.
The Nanonis backend, built on the client of @sec:interface, is the only hardware backend today.
The interface is where further backends attach.

A mock backend implements the same interface without an instrument.
Its frequency shift follows a scriptable model of the tip's response to pulses, and its Z-controller is simulated too.
Faults can be injected on chosen calls, and every call is recorded for inspection.
A seeded random generator makes a simulated run repeatable.
Routines are developed and tested against the mock; @sec:mock-results reports what that covers.

== Routine harness <sec:harness>

A routine is a plain Rust struct implementing the #code("Routine") interface.
Its #code("Routine::run")[`run`] method receives a runtime, #code("Rt").
The runtime absorbs the scaffolding every routine would otherwise reimplement, so the body contains only the measurement logic:

- *Subsystem handles.*
  #code("Rt::bias")[`rt.bias()`], #code("Rt::z")[`rt.z()`], #code("Rt::scan")[`rt.scan()`] and their siblings check the backend's capabilities when obtained and report every operation through them to the event bus.
- *Cancellation.*
  Waits are interruptible, and a stop request surfaces as the outcome "stopped by the operator", not as an error.
- *Budgets.*
  A cycle driver turns cycle and time budgets into outcomes instead of hand-written checks.
- *Cleanup.*
  #code("Rt::guarded")[`rt.guarded`] pairs a body with a cleanup that runs however the body ends, restoring hardware such as a running scan or a changed scan speed.

Around the routine, the harness owns the run.
It prepares the backend and sets what the routine declares it needs (for tip preparation, the Z home position and the safe-tip protection).
It then runs the routine.
Whatever the outcome, it leaves the tip as the routine's exit policy says, restores the protection and tears down.
That includes a panic.
A guard around the routine catches the unwinding, cleans up the hardware and re-raises the panic unchanged.

Two properties follow from the structure rather than from the routine author's care.
The handle is the only route to an operation, and the compiler enforces that every operation takes it.
Obtaining a handle runs the capability check, so a call the backend cannot serve fails there, before any command reaches the instrument.
Whether an operation is legal in the instrument's current state remains the routine's responsibility (@sec:poc-lessons).
The other checks left at run time are those only a live reading can answer, such as the landing gate of @sec:outcomes.

The harness borrows the backend instead of consuming it, so one connection can run routine after routine.
A session builds on this.
It connects once, loads the instrument's layout and settings and starts the data stream.
It then runs jobs one at a time, each with its own log.
Tip preparation is the reference routine, not the only one: measuring and compensating the Z-piezo drift is a second routine on the same harness.
Both can be run from a graphical workbench, which also saves complete operating points, the Z-controller and PLLs with the bias and the scan settings, and applies them in one step.
// Operating points: rusty-tip src/operating_point.rs:1-8 (every loop with its
// setpoint, the bias and the scan's size, angle, resolution and speed,
// captured in one read and applied in one job).

== Event system <sec:events>

Every operation through a handle is reported to an event bus when it starts, completes or fails, with its parameters, duration and result.
Routines add their own typed events.
Tip preparation reports each cycle, phase change and maximum-voltage pulse.
Observers subscribe to the bus: one writes the run to a log file, one prints to the console, one forwards events to the workbench.
One bus thus serves live monitoring, logging and offline analysis.

The log describes itself.
It opens with the tool, its version and source revision, the loaded configuration with every default applied, the resolved signals and stream rate, and a schema for every event type the tool can write.
It closes with the outcome.
A configuration change during tip preparation takes effect between cycles, except for fields frozen at run start.
The log records each change with the full resulting configuration.
The log alone therefore suffices to reconstruct what was run and with which parameters.

The front ends build on the log.
Tip preparation runs from a command-line tool or as a tool of the workbench (@fig:workbench).
Its setup there is a form generated from the configuration's schema, and its run view shows the apex state, the $Delta f$ trace against the sharp window and the pulse voltages.
The view is rebuilt entry by entry from the run's log, so a live run and a log reopened from the tool's history share one code path.
A terminal reader lists, inspects and exports archived logs.
// rusty-tip bin/rusty-tip-gui/tools/tip_prep.rs:1-7 (setup form, run panel),
// run_view.rs:1-6 (the fold, tested equal live and replayed at :381),
// app.rs:104 (History per tool); bin/tip-prep, bin/rt-log.

// Screenshot of 2026-10-27, light theme, replaying
// tip_prep_20261006_133900.jsonl (completed, 119 pulses, 26 min).
#figure(
  image("fig_workbench.png", width: 100%),
  caption: flex-caption(
    [
      The tip-preparation tool of the workbench replaying a logged run of 6 October 2026: apex state, frequency shift after each cycle against the sharp window, the pulse voltages, and the run's last logged events.
    ],
    [The tip-preparation tool of the workbench],
  ),
) <fig:workbench>

== Analyzers and classifiers <sec:analyzers>

// Classifiers generalize what analyzers do; expect analyzers to fold in.

The framework has two ways to turn a measurement into a decision.
An analyzer is a pure function over a frame, so the same code runs live, over archived data and in a test.
A classifier is a model, reached across a boundary that passes the pixels as an npy array and the metadata as JSON, since models are written in Python and the control path is not.
An unreachable model and one that answers wrongly are distinct errors, because only the first justifies falling back to a simpler criterion.
Model, version, latency and verdict enter the log like any other decision.
The classifier boundary is infrastructure so far: no trained model is attached, and tip preparation decides on thresholds of $Delta f$ (@sec:criteria-applied) without consulting either kind.
