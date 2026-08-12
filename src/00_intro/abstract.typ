#import "/report.typ": unnumbered

#unnumbered([Abstract], outlined: false)

// Merged from the two reviewed sources: the motivation and the results follow
// the poster (`~/Projects/typst/tip-prep-poster/main.typ`), which is the later
// and PI-reviewed wording; the framework, outlook and closing sentences follow
// the abstract submitted to NC-AFM 2026. Bracketed numbers became citations.
// Keep the three in step rather than editing them apart.

The quality and interpretability of scanning probe microscopy data critically
depend on the tip termination. Controlled functionalization provides
reproducible contrast and makes surface structures comparable with
computational modeling, and copper-oxide surfaces are among the best-defined
systems for it. Preparing a well-functionalized tip is nevertheless
time-consuming and strongly dependent on operator experience, limiting the
reproducibility and throughput of SPM experiments. Efforts to systematize tip
preparation range from standardized manual protocols @tewari2017 to
machine-learning-assisted automation @alldritt2022, yet operator-independent
conditioning remains the exception.

To overcome this bottleneck, we built an open-source software framework
@rustytip that automates tip preparation on scanning probe microscopes,
independent of the specific instrument or technique. It connects to the
controller through a generalized interface, runs configurable conditioning
routines, and logs every step, so that procedures can be reproduced, optimized,
shared, and compared between groups.

The current routine is a state machine over three apex states. It applies bias
pulses, monitors the frequency-shift response, and evaluates tip quality from
the statistics of bias sweeps, repeating the conditioning cycle until a defined
criterion is met. On a Nanonis-controlled microscope @nanonis, two unattended
runs on partially oxidized Cu(110) started from blunt tips and reached the
sharp bounds within seven minutes; one of them also passed the stability test,
while the other returned to pulsing on its own.

These are the first steps towards autonomous functionalization of SPM tips. The
framework will be extended to incorporate decision-making based on external
image-recognition and numerical analysis, so that the criterion can become a
structure in an image rather than a single frequency-shift value, enabling
controlled and reliable tip functionalization and termination @gross2009
@wiesener2024 for AFM measurements. By transforming these operator-dependent
recipes into shareable workflows, the framework makes reproducible tip
preparation accessible to any laboratory.
