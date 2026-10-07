= Discussion <sec:discussion>

What the results mean, and where they stop being trustworthy.

== Assessment of the architecture <sec:architecture-eval>

Whether the seams of @sec:framework paid for themselves has to be judged
against the failures in @sec:poc-lessons rather than against taste. Two pieces
of evidence need no appeal to preference: the untyped store that ceased to have
a purpose once measurements were typed, and the classifier stack, which
admitted an entirely new kind of decision-maker without the routine or the
control path changing. Set against that, what the abstraction cost.

== Limitations of the frequency-shift criterion <sec:limitations>

One scalar stands in for the state of an atomic-scale apex, and the sharp
window and stability tolerance behind it were calibrated on one instrument and
one surface, so what would have to be re-established elsewhere is an open
question rather than a detail. Together with the parts of the current
implementation that have not yet met a microscope, this is the honest list.

== Comparison with related work <sec:comparison>

Placed next to the alternatives, the trade is legible: standardized manual
protocols @tewari2017 demand operator time and transfer poorly,
machine-learning-driven approaches @rashidi2018 @alldritt2022 demand training
data and a model per instrument, and this work demands that somebody write the
routine down once. What each buys, and what each asks of the person running the
microscope.
