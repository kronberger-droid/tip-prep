#import "/lib.typ": todo

// Sources, all checked against the papers (Zotero collection "Autonomous Tip
// Preparation - STM", or doi.org): giessibl2019 eq. (4)-(6), the caption of
// Fig. 6 for the sign of the force gradient k_ts, and pp. 5-6 for
// Δf and the role of long-range forces; meyer2021 §3.5, p. 81, eq. (3.31)
// for the van der Waals frequency shift ∝ −R (after Guggisberg et al., PRB 61,
// 11151, 2000, not checked here) and eq. (3.30) for the electrostatic one, and
// p. 18 for in-situ tip preparation; wiesendanger1994 p. 198 ("Other
// field emission experiments") for voltage pulses as an in-situ tip treatment
// at high field; ceddia2024
// for blunt/contaminated tips and Scanbot; barker2024, krull2020, wang2021,
// rashidi2018, alldritt2022, tewari2017 from their abstracts and full text;
// wiesener2024 from the arXiv abstract (2402.11045).

= Foundations <sec:foundations>

This chapter summarizes the physical background that the later chapters rely on and reviews prior work on tip conditioning.
The interpretation of the frequency shift as a proxy for apex bluntness in @sec:apex is this work's own inference; all other material is prior work.

Scanning probe microscopy images a surface by scanning it with a sharp tip at a distance small enough for the two to interact.
The measured interaction is either the tunnelling current that flows when a bias voltage is applied between tip and sample @binnig1982, or the force between tip and sample, detected through a cantilever @binnig1986.
With a qPlus sensor, the force is measured through the frequency of the oscillating tip.
The sensor is driven at a constant amplitude $A$, and the conservative part of the tip-sample force $F_"ts"$ shifts its frequency from the eigenfrequency $f_0$ to $f_0 + Delta f$ @giessibl2019.
For a sensor of stiffness $k$, this frequency shift is
$ Delta f = f_0 / (2 k) chevron.l k_"ts" chevron.r $
where $chevron.l k_"ts" chevron.r$ is the force gradient $k_"ts" = - dif F_"ts" \/ dif z$, averaged with a weight over the oscillation @giessibl2019[eq.~4].
For amplitudes small compared to the range of the force, the average reduces to the gradient itself.
The routine of @sec:routine reads this signal.

== Tip apex and terminations <sec:apex>

The geometry and composition of the apex determine what the tip resolves: a blunt tip blurs an image, and a contaminated one increases noise @ceddia2024.

The frequency shift can serve as a proxy for apex bluntness.
The tip-sample force has a short-range part from chemical bonding between the apex atoms and the surface, and a long-range part from van der Waals and electrostatic forces @giessibl2019.
The long-range part does not contribute to atomic resolution, but it grows with the amount of tip material close to the surface, and the proxy rests on this dependence.
The long-range force is weakly distance-dependent but large, and it contributes more to $Delta f$ the larger the oscillation amplitude @giessibl2019.
For a tip modelled as a sphere of radius $R$ whose closest part lies a distance $macron(s)$ from a flat sample, the van der Waals part of the frequency shift at large amplitude $A$ is
$ (Delta f_"vdW") / f_0 k A = - (H R) / (6 macron(s) sqrt(2 macron(s) A)) $
with the Hamaker constant $H$ @meyer2021[eq.~3.31].
The electrostatic part likewise grows with $R$.
At fixed separation and amplitude, a blunter apex thus shifts the frequency further negative.

Reading $Delta f$ at a fixed tunnelling setpoint as a proxy for bluntness is this work's inference.
On a relatively clean surface, the feedback of scanning tunnelling microscopy (STM) sets similar tunnelling conditions from tip to tip, and with them a similar separation.
At nonzero bias, short- and long-range forces both act, but under STM feedback a reasonably sharp tip sits far enough from the surface for the short-range part to contribute little.
$Delta f$ close to zero then indicates a sharp apex.
This is what @sec:routine means by _blunt_ and _sharp_; _stable_ adds that the apex keeps its $Delta f$ under field stress.
The interpretation rests on operator experience; @fig:proxy illustrates it.
// The setpoint step and the short-range caveat: Martin, 2026-10-27.

Controlled functionalization gives the apex a defined termination.
A CO-terminated tip resolved the chemical structure of a single molecule @gross2009.
An oxygen-terminated copper tip (CuO#sub[x]) gives chemically selective contrast between metal and oxygen atoms on a range of metal-oxide surfaces @wiesener2024.
This work uses partially oxidized Cu(110) as its model system, a surface sufficiently defined that a well-prepared tip is recognizable on it.

== Tip conditioning and its systematization <sec:conditioning>

In situ, a tip is reshaped by controlled collision with the surface or by high-field treatment @meyer2021.
Mechanical annealing, repeated indentation into a metal up to a preset conductance, yields tips of reproducible structure @tewari2017.
The routine of @sec:routine applies a high-field treatment instead, in the form of bias pulses @wiesendanger1994[p.~198].

Automated approaches differ mainly in what they judge the tip by.
From images, neural networks recognize degraded tips by the appearance of a known surface @rashidi2018.
In DeepSPM, a network judges image quality while a reinforcement-learning agent conditions the tip over multi-day experiments @krull2020.
Template matching reaches comparable accuracy from a single image without training data, which are costly to label for every surface @barker2024.
Models trained on archived spectra recognize the surface state of gold and condition the tip until that state appears @wang2021.
Scanbot indents the tip into a clean metal on a second sample holder and judges the imprint's area and circularity @ceddia2024.
For functionalization, a pre-trained library finds CO molecules in an image and picks one up @alldritt2022.

None of them judges the tip by a single reading of the frequency shift, taken each time the tip has approached the surface.
