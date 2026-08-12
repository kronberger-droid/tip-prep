= The automation framework <sec:framework>

The framework is the general backend a routine runs on; the routine itself is
@sec:routine. Keeping the two apart is what makes a procedure reproducible,
portable across instruments, shareable and extendable, rather than a script
bound to one microscope.

== Precursor implementations <sec:poc-lessons>

The earlier implementations and what each of them got wrong. This is the
evidence the rest of the chapter answers to, so it comes first, and two
deletions carry most of it.

Measurements were written into a shared store as JSON under string keys and
read back by whoever needed them, which made every consumer a parser and every
schema change a silent breakage. Typing the measurements removed the store's
last writer. A structure that disappears once the types are right was never
carrying the design.

Procedures were data too: actions constructed by name from parameters and
sequenced by a declarative engine with its own loops and conditionals. It
worked, and it was removed, because a general-purpose language had been
reinvented badly inside a configuration file. What replaced it is
@sec:harness; what might yet replace *that* at a better layer is the scripting
question of @sec:outlook. The line drawn afterwards is that a configuration
file owns the numbers of a run and not its control flow, which still leaves an
archived config plus an event log as the reproducible artifact the abstract
promises.

== Hardware abstraction <sec:controller-trait>

A single interface abstracting the capabilities of the underlying instrument,
so a procedure is written against it rather than against a TCP protocol, and
refuses cleanly on hardware that cannot run it.

Each hardware operation is a value holding its own parameters and declaring the
capabilities it needs, checked before anything reaches the instrument. Results
are typed too: a grabbed scan image carries its pixels, channel, direction and
physical geometry as one value rather than as the JSON blob above. Operations
are an implementation detail rather than the authoring surface, which is
@sec:harness.

== Routine harness <sec:harness>

Subsystem handles, interruptible waits, cycle and time budgets, and cleanup
that runs however a step ends, so that a routine body contains only the
science.

Preconditions are checked and the tracked machine state refreshed against the
instrument on demand: safety as a property of the structure rather than of the
operator's discipline. Where a routine is developed without a microscope, the
mock controller supplies the same interface with a scriptable tip model and
fault injection.

== Event system <sec:events>

An event bus carrying each operation with its parameters, duration and result.
One stream serving live monitoring, logging, replay and offline analysis,
rather than logging bolted on afterwards. The command-line tool and the
graphical interface are both built directly on it.

== Analyzers and classifiers <sec:analyzers>

// Classifier design as of PR #15 (feat/frame-classifier) on rusty-tip.
// Classifiers generalize what analyzers do; expect analyzers to fold in.

Two ways for the framework to turn a measurement into a decision. An analyzer
is a pure function over a frame, so the same code runs live, over archived
data, and in a test. A classifier is a model, which brings identity, version,
latency and possibly a network between the routine and the answer.

The trait separates what a classifier answers from how it is reached: models
are written in Python and the control path is not, so the boundary is pixels as
an npy array and metadata as JSON, and a new model costs a verdict type and a
URL rather than transport code. The connection resolves the model's identity at
setup, so an unreachable model is a configuration error at startup instead of a
surprise three hours into an unattended run.

An unreachable model is a distinct, matchable error because falling back to a
simpler criterion is a legitimate response; a model that answers wrongly is
not, since masking a broken deployment hides the thing worth fixing. Model,
version, latency and the verdict itself enter the event stream, which is what
keeps a run driven by a model as accountable as one driven by a threshold.
