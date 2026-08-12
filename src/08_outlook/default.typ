= Outlook <sec:outlook>

The extensions the present design was built to allow, and what each would take.

== Image-based criteria <sec:image-criterion>

The criterion is the first thing to change. Defined terminations such as CO
@gross2009 or CuOx @wiesener2024, and STM, where no frequency shift is
available at all, both require judging a structure in an image rather than a
single value.

The route there is shorter than it was: @sec:analyzers already carries frames
to a model and its verdict back into the routine, so what is missing is a
trained model and the labelled frames to fit it, not the machinery to consult
one.

== Data-driven pulse strategies <sec:learned-policies>

Beyond judging the tip, the same data could choose the pulse. Amplitude,
polarity and timing can be optimized offline against recorded sessions, and
ultimately learned from previous outcomes @alldritt2022 @rashidi2018. The event
log of @sec:events is the dataset, the classifier interface is where a learned
model attaches, and its decisions stay accountable because they are logged like
any other.

The same arrangement scales to a language model driving the microscope through
the existing guards: a model that decides, a boundary it cannot reach past, and
a record of everything it decided.

== Scripting layer and instrument portability <sec:scripting>

The procedure itself could leave Rust for a scripting layer, so that it can be
reviewed, shared and versioned as text. @sec:poc-lessons is the warning
attached to this, since the first attempt put the control flow into a
configuration file and had to be removed.

Alongside it sit the two questions this design was shaped for and has not yet
been asked: what porting to a second controller actually involves, and which
further routines the framework can carry.
