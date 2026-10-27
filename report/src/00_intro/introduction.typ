#import "/report.typ": unnumbered

// Unnumbered, but listed in the contents, matching the \section* followed by
// \addcontentsline in the thesis.
#unnumbered([Introduction])

// The motivation follows the poster's PI-reviewed panel; the prior art is the
// set checked for @sec:conditioning (Zotero). The former chapter "Scope and
// objectives" is folded into the last two paragraphs: the deliverables, what
// "worked" means, and what is out of scope.

The quality and interpretability of scanning probe microscopy (SPM) data
critically depend on the tip termination (@sec:apex). Obtaining a well-prepared
tip is nevertheless time-consuming and strongly dependent on operator
experience, limiting the reproducibility and throughput of SPM experiments. An
operator judges every change to the tip by inspecting the next image, which
makes tip preparation one of the most tedious steps of atomic-resolution work
@barker2024.

Efforts to systematize tip preparation range from standardized procedures
@tewari2017 to machine-learning-assisted automation @rashidi2018 @krull2020
@wang2021 @alldritt2022 (@sec:conditioning), yet operator-independent
conditioning remains the exception. Each of these judges the tip from an image,
a spectrum or an imprint. Most are tied to the surface they were trained or
calibrated on, or to the setup they were written for.

This work builds the conditioning loop around a signal available at every
landing, when the tip is back in feedback after an approach: the frequency
shift $Delta f$ of a qPlus force sensor, read without scanning. It delivers
nanonis-rs, a typed client for the instrument's protocol over the Transmission
Control Protocol (TCP), and rusty-tip @rustytip, a framework for writing SPM
routines against it. Built on both, a tip-preparation routine conditions a tip
by bias pulses until $Delta f$ shows it sharp and stable. The routine counts as
working if it reaches a confirmed sharp tip unattended and ends every run with
the tip withdrawn, whichever way it stops. It must also leave a log from which
the run can be reconstructed. Tip functionalization, instrument backends other than Nanonis,
and learned pulse strategies are deliberately out of scope.

@sec:foundations gives the physics and prior art the work builds on.
@sec:interface, @sec:framework and @sec:routine describe the client, the
framework and the routine. @sec:validation reports the runs on the instrument,
and @sec:discussion and @sec:outlook assess them and say what comes next.
