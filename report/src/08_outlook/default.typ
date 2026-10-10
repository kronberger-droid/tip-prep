= Outlook <sec:outlook>

One planned fix, then the extensions the design was built to allow, and what
each would take.

The nearest change closes the blind spot of @sec:limitations. A reading counts
as a lost lock, not a measurement, when its mean lies within a few percent of
the limit of the PLL's frequency range, or when it shows no noise at all. That
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
learned model attaches. Its decisions stay accountable, logged like any other.

The same arrangement scales to a language model driving the instrument through
the existing guards: a model that decides, a boundary it cannot reach past, and
a record of everything it decided.

The reading half of that boundary exists. A separate command line answers
requests from scripts and agents with JSON over a local socket. Every request
declares whether it acts on the instrument, so a server started read-only
refuses those that do. So far, every request only reads: the status, signal
values, the Z and PLL parameters, the scan frame, and the noise spectrum of a
streamed signal. What remains is the acting half, routed through the same
handles as a routine.
// rusty-tip src/control/mod.rs: Request::acts(); the seven requests
// (describe, status, read, controllers, scan, frame, psd) are all reads.
// Not on the event bus yet: reads go through Session::query.

The routine itself could leave Rust for a scripting layer, to be reviewed,
shared and versioned as text. @sec:poc-lessons is the warning: the first
attempt put the control flow into a configuration file and had to be removed.

Alongside it sit the two questions this design was shaped for but has not yet
been tested against: what porting to a second controller involves, and which further
routines the framework can carry.
