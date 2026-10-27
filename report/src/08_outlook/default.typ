= Outlook <sec:outlook>

One planned fix, then the extensions the design was built to allow, and what
each would take.

The nearest change closes the blind spot of @sec:limitations. A reading counts
as railed, not a measurement, when its mean lies within a few percent of the
limit of the PLL controller's range, or when it shows no noise at all. That
limit is read from the instrument at the start of a run, not configured. On
such a reading the routine withdraws, fires no pulse, withholds the reading
from the pulse strategy, logs the event, and measures again at a fresh site.

A second guard would bound the Z-piezo towards the surface after each landing,
so that the Z-controller cannot drive the tip into the surface between
readings. Its margin would estimate the gap to contact from the bias and
setpoint.
// Planned, not implemented: rusty-tip handover note of 2026-10-07 (DATA
// drive, Tip Prep/rusty-tip-handover-2026-10-07.md), sections 4a and 4b.
// Open there: reposition and continue on a contact, or end the run.

The criterion is the next thing to change. Defined terminations such as CO
@gross2009 or CuOx @wiesener2024 require judging a structure in an image, not a
single value. So does STM, where no frequency shift is available at all.

The route there is shorter than it was. The classifier interface of
@sec:analyzers already carries frames to a model and its verdict back into the
routine. What is missing is a trained model and the labelled frames to fit it,
not the machinery to consult one.

Beyond judging the tip, the same data could choose the pulse. Amplitude,
polarity and timing can be optimized offline against recorded runs, and
ultimately learned from previous outcomes @alldritt2022 @rashidi2018. The logs
of @sec:events are the dataset, and the classifier interface is where a
learned model attaches.

The same arrangement scales to a language model driving the instrument through
the existing guards. The reading half of that boundary exists. The workbench,
or the same server run without a window, answers requests from scripts and
agents as JSON over a local socket, read-only by default. A model can thus
already inspect the instrument and a run for analysis without being able to
move anything. The acting half, routed through the same handles as a routine,
does not exist yet: every request so far only reads.
// rusty-tip src/control/mod.rs:1-18 (workbench socket, `rusty-tip serve`,
// in process) and Request::acts(), false for all seven requests (describe,
// status, read, controllers, scan, frame, psd); server.rs:1-6 for loopback
// TCP; bin/rusty-tip-gui/connection.rs:42-51 for the read-only default.
// Not on the event bus yet: reads go through Session::query.

The routine itself could leave Rust for a scripting layer, to be reviewed,
shared and versioned as text. @sec:poc-lessons is the warning: the first
attempt put the control flow into a configuration file and had to be removed.

Alongside it sit the two questions this design was shaped for but has not yet
been tested against: what porting to a second controller involves, and which further
routines the framework can carry. The workbench gives a first answer to the
second. Besides tip preparation, it hosts drift compensation and a tool that
reads, edits and writes the Z-controller and PLL loops and keeps complete
operating points, every loop with the bias and the scan geometry, to apply in
one step.
// rusty-tip bin/rusty-tip-gui/tools/mod.rs:107-114 (the three tools),
// tools/drift.rs:1-2, tools/controllers.rs:1-15; src/operating_point.rs:1-2.
