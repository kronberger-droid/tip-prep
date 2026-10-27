#import "/lib.typ": todo

// Sources, all checked against the papers (Zotero collection "Autonomous Tip
// Preparation - STM", or doi.org): giessibl2019 eq. (4)-(6) and pp. 5-6 for
// Δf and the role of long-range forces; meyer2021 §3.5, p. 81, eq. (3.31)
// for the van der Waals frequency shift ∝ −R (after Guggisberg et al., PRB 61,
// 11151, 2000, not checked here) and eq. (3.30) for the electrostatic one, and
// p. 18 for in-situ tip preparation; ceddia2024
// for blunt/contaminated tips and Scanbot; barker2024, krull2020, wang2021,
// rashidi2018, alldritt2022, tewari2017 from their abstracts and full text;
// wiesener2024 from the arXiv abstract (2402.11045). 

= Foundations <sec:foundations>

This chapter covers the physics the later chapters lean on and the prior art
beside this work. All of it is prior work, except one inference marked as such
in @sec:apex; this work starts at @sec:interface.

Scanning probe microscopy resolves surfaces by bringing a sharp probe close
enough to interact with them, through a tunnelling current @binnig1982 or
through force @binnig1986. With a qPlus sensor, the frequency shift $Delta f$
of the oscillating probe reports the interaction. This shift is proportional to
the average tip-sample force gradient and, for amplitudes small compared to the
range of the force, to the gradient itself @giessibl2019. The routine of
@sec:routine reads this signal.

== Tip apex and terminations <sec:apex>

The geometry and composition of the apex, not the instrument, set what the
probe resolves: a blunt tip blurs an image, a contaminated one makes it noisy
@ceddia2024.

The frequency shift carries a measure of apex bluntness. The tip-sample force
has a short-range part from the apex atoms and a long-range part from van der
Waals and electrostatic forces @giessibl2019. The long-range part is weakly
distance-dependent but large, and it contributes more to $Delta f$ the larger
the oscillation amplitude @giessibl2019. For a tip modelled as a sphere of
radius $R$ whose closest part lies a distance $macron(s)$ from a flat sample,
the van der Waals part of the frequency shift at large amplitude $A$ is
$ (Delta f_"vdW") / f_0 k A = - (H R) / (6 macron(s) sqrt(2 macron(s) A)) $
with the resonance frequency $f_0$, the stiffness $k$ and the Hamaker constant
$H$ @meyer2021[eq. 3.31]. The electrostatic part grows with $R$ likewise. At
fixed separation and amplitude, a blunter apex thus shifts the frequency
further negative.

Reading $Delta f$ at a fixed tunnelling setpoint as a measure of bluntness is
this work's inference. On a relatively clean surface, STM feedback sets similar
tunnelling conditions from tip to tip, and with them a similar separation. At
nonzero bias short- and long-range forces both act, but under STM feedback a
reasonably sharp tip sits far enough from the surface for the short-range part
to contribute little. $Delta f$ close to zero then indicates a sharp apex. This
is what @sec:routine means by blunt and sharp; stable adds that the apex keeps
its $Delta f$ under field stress. @fig:proxy supports the reading empirically.
// The setpoint step and the short-range caveat: Martin, 2026-10-27.

Controlled functionalization makes the apex a known object. A CO-terminated tip
resolved the chemical structure of a single molecule @gross2009. An
oxygen-terminated copper tip (CuO#sub[x]) gives chemically selective contrast
between metal and oxygen atoms on a range of metal-oxide surfaces
@wiesener2024. This work uses partially oxidized Cu(110) as its model system,
well enough defined that a good tip is recognizable on it.

== Tip conditioning and its systematization <sec:conditioning>

In situ, a tip is reshaped by controlled collision with the surface or by
high-field treatment @meyer2021. The routine of @sec:routine pulses the bias.
Mechanical annealing, repeated indentation into a metal up to a preset
conductance, yields tips of reproducible structure @tewari2017. By hand, an
operator judges every change to the tip from the next topographic image
@barker2024.

Automated approaches differ mainly in what they judge by. Images: neural
networks recognize degraded tips from the appearance of a known surface
@rashidi2018. In DeepSPM, a network judges image quality while a
reinforcement-learning agent conditions the probe over multi-day experiments
@krull2020. Template matching reaches comparable accuracy from a single image
without training data, which are costly to label for every surface
@barker2024. Spectra: models trained on archived spectra recognize the surface
state of gold and condition the tip until it appears @wang2021. Imprints:
Scanbot indents the tip into a clean metal on a second sample holder and judges
the imprint's area and circularity @ceddia2024. Functionalization: a
pre-trained library finds CO molecules in an image and picks one up
@alldritt2022.

All of these judge the tip from an image, a spectrum or an imprint scan. None
judges it by a single reading of the frequency shift, available at every
landing without scanning. That reading is where this work starts.
