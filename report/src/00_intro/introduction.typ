#import "/report.typ": unnumbered
#import "/lib.typ": note

#unnumbered([Introduction])

The quality and interpretability of scanning probe microscopy (SPM) data critically depend on the tip termination (@sec:apex).
Obtaining a well-prepared tip is nevertheless time-consuming and strongly dependent on operator experience, limiting the reproducibility and throughput of SPM experiments.
An operator judges every change to the tip from the live signals, mainly the tip height, the tunnelling current, the frequency shift and the oscillation amplitude, or from the image quality, which makes tip preparation one of the most tedious processes in atomic-resolution SPM @barker2024.

Efforts to systematize tip preparation range from standardized procedures @tewari2017 to machine-learning-assisted automation @rashidi2018 @krull2020 @wang2021 @alldritt2022 (@sec:conditioning), yet operator-independent conditioning remains the exception.
The automated approaches judge the tip from an image, a spectrum or the imprint it leaves in a clean metal surface @ceddia2024.
Most are tied to the surface they were trained or calibrated on, or to the setup they were written for.

This work builds the conditioning loop on a signal that can be interpreted without image analysis: the frequency shift $Delta f$ of a qPlus force sensor, read each time the tip has approached the surface.
It delivers nanonis-rs, a typed client for the instrument, which is programmed over the Transmission Control Protocol (TCP), and rusty-tip @rustytip, a framework for writing SPM routines against that client.
Built on both, a tip-preparation routine conditions a tip by bias pulses until $Delta f$ indicates a sharp apex that holds at further sites and, optionally, under bias sweeps.
The routine is considered successful if it reaches a confirmed sharp tip unattended and ends every run with the tip withdrawn, regardless of the outcome.
It must also leave a log from which the run can be reconstructed.
Tip functionalization, instrument backends other than Nanonis, and learned pulse strategies are out of scope, but the design was built to allow each of them (@sec:outlook).

@sec:foundations gives the physics and prior art the work builds on.
@sec:interface, @sec:framework and @sec:routine describe the client, the framework and the routine.
@sec:validation reports the runs on the instrument, and @sec:discussion and @sec:outlook assess them and outline further work.
