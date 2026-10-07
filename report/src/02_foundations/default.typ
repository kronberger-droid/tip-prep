= Foundations <sec:foundations>

The physics the later chapters lean on, the prior art this work sits next to,
and the technology it was handed. Everything in this chapter is somebody
else's; @sec:interface onwards is this work.

Scanning probe microscopy resolves surfaces by bringing a sharp probe close
enough to interact with them, whether through a tunnelling current @binnig1982
or through force @binnig1986. With a qPlus sensor the quantity that reports on
that interaction is the frequency shift $Delta f$ of the oscillating probe
@giessibl2003, and it is the signal the routine of @sec:routine reads.

== Tip apex and terminations <sec:apex>

What the probe resolves is set by its outermost atoms, which makes the apex
rather than the instrument the limiting component. What "blunt", "sharp" and
"stable" mean in measurable terms.

Why controlled functionalization is worth the trouble: CO-terminated tips
resolve molecular structure @gross2009, CuOx tips image oxide surfaces with
chemical selectivity @wiesener2024. Partially oxidized Cu(110) is the model
system this work develops against, well enough defined that a good tip is
recognizable on it.

== Tip conditioning and its systematization <sec:conditioning>

Bias pulsing, controlled indentation and field emission as the manual
repertoire, applied by feel and judged by eye.

Efforts to make this systematic run from standardized protocols @tewari2017 to
machine-learning-driven automation @rashidi2018 @alldritt2022. Where each of
them stops is what leaves room for this work.

== The Nanonis control system <sec:nanonis-controller>

The controller @nanonis can be programmed through LabVIEW, through the vendor's
Python bindings, or over TCP. What that TCP interface specifies is described
here as given technology; what was built on it is @sec:interface.
