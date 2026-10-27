#import "/report.typ": unnumbered

#unnumbered([Abstract], outlined: false)

// Merged from the two reviewed sources: the motivation follows the poster
// (`../../../poster/main.typ`), which is the later and PI-reviewed wording;
// the framework, outlook and closing sentences follow the abstract submitted
// to NC-AFM 2026. Bracketed numbers became citations. The results sentence
// departs from both on purpose: theirs reports two runs of 29 January 2026 on
// the earlier code, this one the runs @sec:validation counts. The interface
// sentence also departs from the submitted abstract, to match
// @sec:architecture-eval (one backend so far).

The quality and interpretability of scanning probe microscopy data critically
depend on the tip termination. Controlled functionalization provides
reproducible contrast and makes surface structures comparable with
computational modeling, and copper-oxide surfaces are among the best-defined
systems for it. Preparing a well-functionalized tip is nevertheless
time-consuming and strongly dependent on operator experience, limiting the
reproducibility and throughput of SPM experiments. Efforts to systematize tip
preparation range from standardized procedures @tewari2017 to
machine-learning-assisted automation @alldritt2022, yet operator-independent
conditioning remains the exception.

To overcome this bottleneck, we built an open-source software framework
@rustytip that automates tip preparation on scanning probe microscopes,
designed to be independent of the specific instrument or technique. It
connects to the controller through an instrument-independent controller
interface, so far implemented for Nanonis, runs configurable conditioning
routines, and logs every step, so that procedures can be reproduced, optimized,
shared, and compared between groups.

The current routine is a state machine over three apex states. It applies bias
pulses and judges the tip from the frequency shift read after each one. A tip
that reads sharp must hold at further sites and, optionally, under bias sweeps
while scanning, and the conditioning loop repeats until it does. On a
Nanonis-controlled microscope @nanonis, 106 runs on partially oxidized Cu(110)
over three weeks gave 53 confirmed sharp tips without an operator. In 41 of
them the routine started from a blunt tip and needed a median of 11 pulses and
2.4 minutes; the other 53 runs were stopped to change parameters.

These are the first steps towards autonomous functionalization of SPM tips. The
framework will be extended to incorporate decision-making based on external
image-recognition and numerical analysis, so that the criterion can become a
structure in an image rather than a single frequency-shift value, enabling
controlled and reliable tip functionalization and termination @gross2009
@wiesener2024 for AFM measurements. By transforming these operator-dependent
recipes into shareable workflows, the framework makes reproducible tip
preparation accessible to any laboratory.
