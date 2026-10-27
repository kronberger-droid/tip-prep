# Glossary

Status: locked (author decisions D7 to D13, 2026-10-27)
Acronym convention: once per document (body), as "long form (ABBR)" at first
use. The abstract is front matter and keeps its own text.

Line numbers are as of 2026-10-27, read while another sweep was still editing
ch2, ch3, ch4, ch8 and the introduction; re-check a line before acting on it.
File shorthand: `abs` = src/00_intro/abstract.typ, `intro` =
src/00_intro/introduction.typ, `02` to `08` = src/0N_*/default.typ, `A` =
src/A_appendix/default.typ.

## Terms

| Canonical | Variants | Where |
|---|---|---|
| tip ("probe" only inside "scanning probe") | probe | 02:19, 02:22, 02:30, 02:75; the drift script also hits "scanning probe" at abs:12, abs:24, intro:12, 02:19, which are false positives |
| apex state | tip state | abs:30, 05:21 (apex states); 04:154, 04:168 (tip state) |
| frequency shift | | abs:31, intro:27, 02:21 (glossed twice: intro and ch2) |
| sharp window | | 04:154, 04:169 (before definition), 05:23, 05:118, A:57 |
| clamp | | 05:75, 05:85; `linear_clamp` at A:100 is code |
| pulse strategy | | 05:59, 06:113; `pulse_method` at A:89 is a config section header (code) |
| bias pulse | | 05:16, 05:39, intro:30 |
| maximum-voltage pulse | | 04:135, 05:145, 06:100, 06:183 |
| cycle | conditioning cycle | one pulse cycle: 05:39, 05:49, 04:134, A:58 |
| conditioning loop | conditioning cycle (as the whole repeat) | the whole repeat: intro:26; abs:33 now "the conditioning loop repeats until it does" |
| reading (the batch, judged by its mean; "interpretation" for the other sense) | | 05:100-103 (a reading is a batch), 05:109, 06:131, 08:6-7 |
| batch | | 05:100, 05:103-113, 07:58 |
| measurement gates (noise and drift gates) | both gates; the gates | 05:103-113, 06:137, 07:61 |
| noise gate | | 05:104, 06:151 |
| drift gate | | 05:104, A:79 |
| landing gate | this criterion | 04:120, A:55, A:70-71, 05:164-167 |
| landing | | intro:27 (glossed: "when the tip is back in feedback after an approach"), 02:86, 05:164 |
| calibrated approach | | 04:145 (before definition), 05:161 |
| confirmation readings | | 05:129, 06:68, 06:91, 06:181 |
| stability test | | 05:133, 05:150, 06:97, A:82 |
| railed reading (introduced in ch6) | reading at the limit; edge of the range | 07:61, 08:7 (railed); 06:133, 06:153, 07:59, 08:8 (limit of the PLL controller's range); 06:67 (edge of the range); 06:65 (from one limit to the other) |
| fresh site | further sites; next sites | 05:23, 05:40, 05:134; abs:32; 06:93 |
| coarse step (lateral, "per lateral axis"); coarse Z retract (the Z move) | Z retract; coarse retract; coarse Z steps; backs off two steps; per axis | 05:43, 05:52, A:67 (x and y), 06:120 ("3 per axis, Z retract 3"), 05:54 (coarse retract), A:75 |
| withdrawal | withdraw (as a noun) | 03:123, 05:179; A:73 ("a full withdraw"), A:75 ("the final withdraw") |
| outcome | ending; endings | 04:101-102, 05:154, 04:143; 06:161 ("each ending"), 06:184 (table group "Endings") |
| time budget | time limit | 05:155-159, A:59; 04:102 ("cycle and time limits") |
| cycle budget | cycle limit | 05:154-155, 06:187; A:58 ("cycle budget") |
| approach timeout | time budget (of an approach) | 05:158, A:73-74 |
| safe-tip protection | safe-tip (bare noun); safe-tip settings | 04:109, 05:159, 05:169; A:62 ("current at which safe-tip retracts"); 05:180 |
| Nanonis controller | the controller (bare) | 03:19, 03:28, 05:101, 05:169; abs:25-26 ("connects to the controller") |
| instrument | microscope | passim; abs:34 (abs:24 "scanning probe microscopes" is generic, not the instrument) |
| controller interface ("interface" only for this and the `Routine` interface) | generalized interface; controller trait; TCP interface -> TCP protocol | 04:27, 04:69-70, 07:27, 07:35; abs:26 ("generalized interface"); label now `<sec:controller-interface>` |
| instrument protocol client (ch3 title; nanonis-rs) | The instrument interface | 03:16 |
| backend | | 04:71, 04:75-76, 07:35-40, 07:96 |
| Nanonis backend ("client" stays for nanonis-rs) | Nanonis client (as backend) | 07:36; 04:75 ("The Nanonis client ... is the only hardware backend") |
| mock backend | | 04:84, 04:88, 06:158; 07:35-37 |
| handle | | 04:28, 04:97, 04:115-116, 04:132, 08:41 |
| harness | | 03:123, 04:52, 04:91, 04:107, 07:23, 07:27 |
| event bus | | 04:29, 04:99, 04:132-137 |
| log; log entry | record (for the event log; the data logger's records in ch3 stay) | 04:65, 04:136-149, 04:155 ("record by record from the run's log"), 04:143 ("Every entry") |
| workbench (first use may say "a graphical workbench") | graphical workbench; graphical interface | 04:152, 04:167, 08:37, 08:55; 04:127, 04:136-137 (graphical interface) |
| classifier boundary | classifier interface; classifier stack; classifier side; classifier transport | 08:26, 08:33; 07:20 (stack); 04:184 (side); 06:194, 06:206 (transport) |
| routine | | passim; abs:27 ("so that procedures can be reproduced") |
| standardized procedure(s) (body; @tewari2017) | defined procedure(s) | intro:19, 07:77; abs:19 (all for @tewari2017) |
| machine-learning-assisted (body) | machine-learning-driven | intro:20; abs:20 (@alldritt2022 in both) |
| well-prepared tip (intro, ch2) | good tip; well-functionalized tip | intro:13, 02:63; abs:16 keeps its own wording |
| CuO#sub[x] | CuOx | 02:60; 08:23 |
| modelled | modeling | 02:37; abs:15 (British vs American spelling) |
| Z-controller and PLLs | PLL loops | 04:72; 08:57-58 ("PLL loops", "every loop") |

## Symbols

| Symbol | Meaning | Defined at |
|---|---|---|
| $Delta f$ | frequency shift of the oscillating qPlus sensor | intro:27 (again at 02:21) |
| $Delta f_"vdW"$ | van der Waals part of the frequency shift | 02:39-40 |
| $R$ | radius of the tip modelled as a sphere | 02:38 |
| $macron(s)$ | distance of the sphere's closest part from the sample | 02:38 |
| $A$ | oscillation amplitude | 02:39 |
| $f_0$ | resonance frequency | 02:41 |
| $k$ | stiffness | 02:41 |
| $H$ | Hamaker constant | 02:41-42 |
| $n$ | period of the polarity reversal: every $n$-th pulse at the opposite polarity | 05:93, 06:116-118, A:96 |
| $tilde.op$ | marks a cycle phase whose length a gate decides (fig:cycle) | 05:51-52 |

## Abbreviations

| Abbreviation | Expansion | First expanded | First used |
|---|---|---|---|
| SPM | scanning probe microscopy | intro first sentence ("scanning probe microscopy (SPM) data") | intro |
| STM | scanning tunnelling microscopy | 02:47-48 | 02:48 (also 06:16, 06:48, 07:87, 08:24) |
| AFM | not expanded | never | abs:44 |
| NC-AFM | non-contact atomic force microscopy | 06:16 (first body use); written "NC-AFM", not "nc-AFM" | 06:16 |
| NC-AFM (conference) | conference name, comment only | n/a | abs:8 (comment) |
| PLL | phase-locked loop | 04:72 | 04:72 |
| TCP | Transmission Control Protocol | first body use | intro:28 |
| CO | not expanded | never | 02:58 |
| CuO#sub[x] | oxygen-terminated copper tip | 02:59-60 | 02:60 |
| vdW | van der Waals | 02:34-35, 02:39 | 02:40 (subscript) |
| JSON | not expanded (stays) | never | 04:57 |
| npy | not expanded (stays) | never | 04:180 |
| HTTP | not expanded (stays) | never | 06:207 |
| I/O | not expanded (stays) | never | 03:114 |
| DeepSPM | name | 02:74 | 02:74 |
| Auto-CO-AFM | name of @alldritt2022 | never tied to the ch2 description | 07:83 (02:81-83 describes it unnamed) |

## Decompositions

| Name | Members | Where |
|---|---|---|
| three apex states | blunt, sharp, stable | abs:30 (count only), 05:21-22, 02:53-54 |
| three pulse strategies | fixed, stepping, linear | 05:59-79, 06:113-115, 06:174-177, A:90 |
| two measurement gates (reading) | noise gate, drift gate | 05:103-104, 06:137, 06:151, 07:58-61 |
| landing gate | separate from the measurement gates; the landing criterion | 04:120, A:55, A:70-71, 05:164-167 |
| four outcomes | completed, cycle budget reached, time budget exhausted, stopped by the operator | 05:154-155 |
| "Endings" in tab:coverage | completed, stopped by the operator, cycle budget reached (time budget missing) | 06:184-187 |
| three confirmation readings | three further readings at fresh sites | 05:127-130, 06:68 |
| four error variants | connection failure, timeout, protocol violation, instrument error | 03:93-95 |
| three earlier structures | declarative engine (with registry), machine-state model, shared store; the text names four things | 04:38-61 |
| runtime scaffolding | subsystem handles, cancellation, budgets, cleanup | 04:97-105 |
| three observers | log file, console, workbench | 04:135-137 |
| two ways to a decision | analyzer, classifier | 04:177-180 |
| two front ends (drift routine) | workbench, `const-distance` tool | 04:127-128, 07:23 |
| two backends | Nanonis backend, mock | 07:35-36 |
| deliverables | nanonis-rs, rusty-tip, tip-preparation routine | intro:28-30 |
| working criteria | confirmed sharp tip unattended, tip withdrawn, reconstructable log | intro:31-34 |
| run counts | 106 = 53 completed + 53 stopped; 53 = 41 with pulses + 12 without | abs:34-37, 06:57-64 (consistent) |
| planned guards | railed-reading guard, Z-piezo bound | 08:6-17 |
| workbench tools | tip preparation, drift compensation, controller tool | 08:56-58 |

## Tense

| Chapter | Results narrated in |
|---|---|
| Abstract | present for the framework; past for the runs (abs:34-37) |
| Introduction | present |
| 2 Foundations | present; past for single prior results (02:58-59) |
| 3 Instrument protocol client | present |
| 4 Framework | present; past for the precursors (04:38-61) |
| 5 Routine | present |
| 6 Results | past for runs; present for figures and interpretation of limits (06:133-136); 06:203-209 mixes past ("were tested", "ran") and present ("cover", "is tested", "checks") in one paragraph |
| 7 Discussion | present for assessment; past for project history (07:26-32) |
| 8 Outlook | future for the planned guard (08:6-12), conditional for the second guard (08:14-17), present for what exists (08:26-42) |
| Appendix | present |

## Conflicts

Resolved by the author, 2026-10-27, one line each:

- D7 interface: "interface" only for `SpmController` (controller interface) and `Routine`; ch3 is "The instrument protocol client"; "TCP interface" -> "TCP protocol"; "graphical interface" -> "workbench"; classifier -> "classifier boundary"; label is `<sec:controller-interface>`.
- D8 abstract: "an instrument-independent controller interface, so far implemented for Nanonis", and "designed to be independent of the specific instrument or technique"; the source comment notes the departure from the submitted abstract.
- D9 prior art: body says "standardized procedure(s)" (@tewari2017) and "machine-learning-assisted"; "good tip" -> "well-prepared tip" (intro, ch2); abstract unchanged on these.
- D10 reading: a reading is the batch of samples, judged by its mean; ch2's interpretive "reading" -> "interpretation".
- D11 gates: "the measurement gates" = noise and drift gates; ch5's landing criterion is "the landing gate"; "railed" is introduced in ch6 where those readings are first counted.
- D12 apex state: "apex state", not "tip state".
- D12 cycle: "cycle" = one pulse cycle; "conditioning loop" = the whole repeat.
- D12 budgets: "time budget" and "cycle budget" for the run limits; the approach's limit is the "approach timeout".
- D12 log: "log entry"/"entries" for the event log; the data logger's "records" (ch3) stay.
- D12 backend: "Nanonis backend" for the `SpmController` implementation; "client" stays for nanonis-rs.
- D12 coarse moves: "coarse Z retract" is the one name for the coarse Z move; lateral steps are "per lateral axis".
- D12 notation: CuO#sub[x], not CuOx; "PLLs", not "PLL loops"; ch2 "tip", not "probe", except in "scanning probe".
- D13 abbreviations: SPM, TCP and NC-AFM ("NC-AFM", not "nc-AFM") expanded "long form (ABBR)" at first body use; abstract keeps its text; JSON, HTTP, npy, I/O stay unexpanded.

Findings that led to them (historical; the decisions above win):

- "interface" carries six senses: ch3 title "The instrument interface" (03:16) is nanonis-rs; "the TCP interface" (03:21) is the vendor's TCP route; "controller interface" (04:27, 04:69, 07:27, 07:35) is `SpmController`; "`Routine` interface" (04:93) is a second trait; "graphical interface" (04:127, 04:136-137) is the workbench; "classifier interface" (08:26, 08:33). Proposed: keep "interface" for the two Rust traits; rename ch3 [resolved D7: "The instrument protocol client"]; 03:21 "TCP interface" -> "TCP protocol"; 04:127/04:136 -> "workbench" (introduce it at 04:127, its first use); classifier -> see below.
- `<sec:controller-trait>` (04:67, refs 04:60, 06:160) survives the trait-to-interface decision; labels are invisible to the reader, rename only if the author wants source and text aligned.
- "standardized procedures" (abs:19) vs "defined procedures" (intro:19) vs "A defined procedure" (07:77), all @tewari2017: pick one [resolved D9: "standardized"]; the abstract is the submitted wording.
- "machine-learning-assisted" (abs:20, @alldritt2022 only) vs "machine-learning-driven" (intro:20, four refs): pick one [resolved D9: "machine-learning-assisted"].
- "NC-AFM" appears only in a comment (abs:8, the conference); prose has only "nc-AFM" (06:16), never expanded. "AFM" at abs:44 also unexpanded. Expand at first body use (06:16) [resolved D13].
- STM: now expanded at 02:47-48 ("scanning tunnelling microscopy (STM)"); clean.
- PLL: expanded at its first use 04:72, but inside a capability list that does not say what it does; what it does appears only at 06:133-135 ("what the PLL follows"). Consider a functional gloss at 05:162.
- "landing": now glossed at first use intro:27 ("when the tip is back in feedback after an approach"); the gloss leans on "feedback" and "approach", which the reader meets later (05:161). The criterion at 05:164-167 is never called "landing gate", yet 04:120 points to "the landing gate of @sec:outcomes" and A:55, A:70-71 use the name. Name it at 05:164.
- reading vs batch vs value: 05:100-103 defines "a reading is a batch of samples ... Its value is the batch mean", and 08:7 gives a reading "its mean"; GLOSSARY.md row 1 defines a reading as the accepted value. 05:109-110 swaps reading and batch within two sentences; 06:137 says readings "failed the gates". Decide whether a reading is the batch or its mean [resolved D10: the batch, judged by its mean]. Separately, 02:54 "supports the reading empirically" and 02:86 "That reading is where this work starts" use "reading" for interpretation, right next to the measurement sense (02:85); rephrase 02:54 ("supports this interpretation").
- "gate": the text has three gates (noise, drift, landing) but says "two gates" (05:103) and "both gates" (06:137, 07:61) for the reading pair only; 05:52 caption "a gate decides" does not say which. 08:37 "the existing guards" is unclear, since the guards of 08:6-17 are planned; say which existing checks are meant.
- "classifier stack" (07:20) is PR-stack jargon from the branch comment (04:5-6); 08:26/08:33 say "classifier interface", 04:184 "classifier side", 06:194/06:206 "classifier transport". 04:179 calls it "a boundary". Pick one [resolved D7: "classifier boundary"] ("classifier interface" adds a seventh "interface"; "classifier boundary" avoids it).
- "pulse strategy" vs `pulse_method`: prose is consistent; `pulse_method`/`PulseMethod` occur only as a config section header (A:89) and comments. Clean.
- "probe" vs "tip": ch2 alternates within one sentence (02:29-30 "the apex ... set what the probe resolves: a blunt tip"); 02:75 "conditions the probe" (DeepSPM). Use "tip" outside "scanning probe" [resolved D12].
- "good tip" (intro:13, 02:63) vs "well-functionalized tip" (abs:16) vs "sharp" (technical, 05:118): the abstract promises functionalization while intro:34 puts it out of scope. "good" is never defined; 02:63 could point to @fig:proxy.
- "coarse step per axis" (05:43, 05:52) vs A:67 "in x and y" vs 06:120 "3 per axis, Z retract 3": a reader cannot tell whether "axis" includes Z. Say "per lateral axis" or "in x and y" [resolved D12: "per lateral axis", "coarse Z retract"]. The coarse Z move has four names: "coarse retract" (05:54), "Z retract" (06:120), "backs off two steps" (05:178), "coarse Z steps back" (A:75).
- "railed reading": coined at 07:61 with only a description before it (07:59-60); its criterion arrives later (08:6-8). Ch6 describes the same readings as "limits of the PLL controller's range" (06:133), "edge of the range" (06:67), "from one limit to the other" (06:65). Introduce "railed" at 06:133 or drop it [resolved D11: introduced in ch6].
- "sharp window" vs "clamp": definitions are distinct and consistent (05:75-79, 05:118); but "sharp window" is used in ch4 (04:154, 04:169) before ch5 defines it (05:23, 05:118). Acceptable as a forward mention in a figure caption, or add a pointer.

Other cross-chapter findings:

- Thesis tie: abs:26 "generalized interface" and abs:24-25 "independent of the specific instrument or technique", abs:45-46 "accessible to any laboratory" vs 07:34-41 ("a design intention, not a result"; a second backend "is the minimum for calling the interface general") and 07:96 ("bound to one vendor"). The abstract claims what ch7 withholds.
- Term order: "calibrated approach" 04:145 before 05:161; "safe-tip protection" 04:109 before 05:169; "Z home position" (04:108) and "exit policy" (04:110) are never defined; "creep" (05:44) undefined; Auto-CO-AFM named first at 07:83 though ch2 describes it unnamed (02:81-83); "harness" and "session" used in ch3 (03:118, 03:123) before ch4, via @sec:harness.
- Decomposition: tab:coverage "Endings" (06:184-187) lists three outcomes and omits "time budget exhausted" (05:155). Either add the row or say why it is left out.
- Decomposition: "Three earlier structures" (04:38) vs four named parts (engine, registry, state model, store, 04:41-61); say the registry belongs to the engine, or count four.
- "cycle": one pulse, move and reading in ch5 (05:39, fig:cycle 05:49) and ch4 (04:134); but abs:33 "the conditioning cycle repeats until it does" means the whole pulse-confirm-test sequence, and intro:26 "conditioning loop" the routine. 05:32 uses "loop" per state. One word each [resolved D12: "cycle", "conditioning loop"].
- "outcome" (04:101, 05:154) vs "ending" (06:161, 06:184): use "outcome".
- "time budget" (05:155, A:59) vs "time limit" (04:102); "cycle limit" (05:154, 06:187) vs "cycle budget" (A:58). The approach timeout is also a "time budget" (05:158, A:73-74), so "time budget" names two things [resolved D12: "approach timeout"].
- "withdraw" as a noun at A:73 and A:75; the text uses "withdrawal" (03:123, 05:179).
- "log records" (04:155) collides with the data logger's "records" (03:64); 04:143 says "entry". Pick "entry" for the log [resolved D12: "log entry"].
- 04:75 "The Nanonis client of @sec:interface is the only hardware backend" conflates nanonis-rs (the client) with the backend that wraps it (07:36 "Nanonis backend").
- abs:25-26 "connects to the controller" uses bare "the controller", which elsewhere is generic; 07:79, 07:96, 08:54 use "controller" for any vendor's control system. Clear enough, but abs:26 could read "the instrument".
- abs:27 "so that procedures can be reproduced" uses "procedures" for routines; abs:45 adds "recipes" and "workflows".
- 08:57-58 "PLL loops" (phase-locked loop loops) and "every loop" call the Z-controller and PLL "loops".
- CuO#sub[x] (02:60) vs plain "CuOx" (08:23).
- Spelling: abs:15 "modeling" (American) vs 02:37 "modelled", 04:80 "centre", 05:126 "favourable" (British).
- Frequency shift glossed twice: intro:27 and 02:21-22. Fine if ch2 is meant to be self-contained; otherwise drop one gloss.
- 06:203-209 mixes past and present in one paragraph (see Tense).
- Acronyms never expanded: TCP (intro:28), JSON (04:57), npy (04:180), HTTP (06:207), I/O (03:114), CO (02:58), AFM (abs:44), nc-AFM (06:16). SPM is never expanded in parentheses (long form abs:12/intro:12, short form abs:18/intro:15) [resolved D13: SPM, TCP, NC-AFM expanded; JSON, HTTP, npy, I/O stay].

GLOSSARY.md (developer glossary) vs the current text:

- Row 1 (reading = one accepted value, the mean of a batch): the text defines a reading as the batch (05:100) whose value is the mean (05:103).
- Row 10 (avoid bare "the controller"): abs:26.
- Row 11 ("the controller trait (`SpmController`)"): the author chose "controller interface" (04:27, 04:69, 07:27, 07:35). The label `<sec:controller-trait>` remains. Row 11's "the Nanonis backend" is used at 07:36 but 04:75 says "Nanonis client".
- Row 13 (no bare "loop" for the PLL): 08:57-58. The expansion rule (once, ch4) holds at 04:72.
- Row 14 (the repeated cycle = "loop, pulse loop, conditioning loop"): the text uses "cycle" (05:39, 04:134, A:58); "loop" survives at intro:26 and 05:32 in other senses; "pulse loop" does not occur.
- Row 15 (feedback controller, ch3 slope encoding): no longer in prose; only the comment at 03:107-110.
- Row 17 ("record" for a logging-port sample set): 04:155 uses "record" for log entries.
- Row 24 (routine, not procedure): abs:27 "procedures"; Tewari's "defined procedure" (07:77) is the allowed exception, abs:19 "standardized procedures" is the same citation.
- Row 26 (safe-tip protection): A:62 uses bare "safe-tip".
- Row 9 (instrument, not microscope): abs:24, abs:34.
- Row 3 (ch5 heading "Bias pulses and pulse strategies"): now matches (05:37).

## Reader glossary (appendix draft)

Grounding for each entry, from the report's own text. `(no definition in text)`
means the report uses the term without defining it; those cells carry a
`#todo` in the Typst draft below so they show up purple.

| Term | Definition (from the text) | Grounded in |
|---|---|---|
| $Delta f$, frequency shift | Shift of the oscillating tip's frequency on a qPlus sensor, proportional to the average tip-sample force gradient; the routine reads it after every pulse. | 02:21-24, 05:18-19 |
| qPlus sensor | The force sensor whose frequency shift $Delta f$ reports the tip-sample interaction. | intro:27, 02:21-22 |
| SPM | Scanning probe microscopy (SPM): resolving a surface with a sharp tip close enough to interact with it, through a tunnelling current or through force. | intro:12-15, 02:19-21 |
| STM | Scanning tunnelling microscopy (STM); on a relatively clean surface its feedback sets similar tunnelling conditions, and so a similar tip-sample separation, from tip to tip. | 02:47-50 |
| NC-AFM | Non-contact atomic force microscopy (NC-AFM); with STM, what the instrument of the counted runs is built for. | 06:16 |
| PLL | Phase-locked loop (PLL); it follows the frequency shift up to the limits of its range. | 04:72, 06:133-135 |
| Z-controller | The instrument's feedback to a current setpoint; held during a pulse and switched back on to land the tip. | 05:39, 05:163-165, A:61 (inferred from use; the text never says what the Z-controller is) |
| Safe-tip protection | The Nanonis controller's protection that retracts the tip when the current exceeds a threshold, $1$ nA by default; the routine keeps it off except while the tip is backed off. | 05:169-173 |
| Apex | Its geometry and composition, not the instrument, set what the tip resolves. | 02:29-31 ("end of the tip" is not in the text; no definition of the word itself) |
| Blunt, sharp, stable | The three apex states: sharp when $Delta f$ lies inside the sharp window, blunt otherwise, stable when a sharp tip keeps its $Delta f$ through the stability test. | 05:21-25, 05:118, 02:52-54, 05:143-144 |
| Sharp window | The configured interval of $Delta f$, bounds included, inside which a tip counts as sharp; a run parameter. | 05:118-119 |
| Bias pulse | A pulse of the bias, $50$ ms by default, fired with the Z-controller on hold; it reshapes the apex through the field at it. | 05:39, 05:147-149, A:65 |
| Pulse strategy | The rule, fixed, stepping or linear, that chooses the next pulse voltage; set in the run's configuration. | 05:59-79 |
| Clamp | The configured $Delta f$ interval below the sharp window over which the linear strategy raises the voltage with distance from the window. | 05:75-79 |
| Cycle | One bias pulse, a move to a fresh site, and a $Delta f$ reading. | 05:39-41, 05:49 |
| Conditioning loop | The whole repeat of cycles, confirmation readings and, optionally, the stability test, until a tip holds through them. | abs:33-36, intro:27 |
| Fresh site | A place on the sample away from the spot the last pulse modified. | 05:40-42 |
| Coarse step | One step of the coarse motor; a move to a fresh site takes one per lateral axis by default. | 05:42-44, A:67 |
| Coarse Z retract | Coarse steps of the tip away from the surface in Z; part of a move to a fresh site, and two steps after the final withdrawal by default. | 05:176-178, fig:cycle caption, 06:120, A:75 |
| Calibrated approach | Approach, back off $50$ nm, centre the PLL's frequency shift there, then land again by switching the Z-controller on; every approach of the routine is one. | 05:161-164 |
| Landing | The tip back in feedback after an approach; it counts once the tunnelling current is within $50 %$ of the setpoint and has stopped scattering and drifting. | intro:27, 05:164-166 |
| Landing gate | The criterion that decides when a landing counts; after $30$ s it gives up with a warning. | 05:164-167, A:70-71, 04:120 |
| Reading | A batch of samples from the data stream, $100$ by default, judged by its mean. | 05:100-103 |
| Noise gate, drift gate | The measurement gates, the two checks on a reading: the batch's standard deviation and the slope of a linear fit through it. A batch failing either is retried, then used anyway. | 05:103-110 |
| Railed reading | A reading at the limit of the PLL controller's range, $plus.minus 76.29$ Hz in the counted runs; it passes both measurement gates. | 06:131-137, 07:59-61 |
| Confirmation readings | The three further readings, each at a fresh site, that a tip inside the sharp window must keep inside it. | 05:126-130 |
| Stability test | Bias sweeps while scanning, at a fresh site per polarity; the tip is stable if $Delta f$ before and after differ by at most a tolerance, $0.2$ Hz by default. | 05:132-144 |
| Maximum-voltage pulse | The pulse at the strategy's maximum voltage fired after a failed stability test, with the tip still engaged. | 05:144-148 |
| Run | One execution of the routine, ending in one of four outcomes: completed, cycle budget reached, time budget exhausted, or stopped by the operator. | 05:154-155 |
| Cycle budget, time budget | The run limits, unset for none; an approach is bounded separately by the approach timeout. | 05:154-159, A:58-59, A:73-74 |
| Routine | A plain Rust struct implementing the `Routine` interface; it owns the control flow. | 04:93, 04:26-27 |
| Controller interface | `SpmController`, the one interface a routine targets to reach the instrument. | 04:69-70 (@sec:controller-interface) |
| Backend | An implementation of the controller interface; it reports its capabilities, and an operation needing a missing one fails before any command reaches the instrument. | 04:70-74 |
| Mock backend | A backend without an instrument: a scriptable $Delta f$ response to pulses, a simulated Z-controller, injectable faults and recorded calls. | 04:84-88 |
| Subsystem handle | The only route to an operation (`rt.bias()`, `rt.z()`, ...); obtaining one checks the backend's capabilities, and every operation through it is reported to the event bus. | 04:97-99, 04:114-117 |
| Harness | Owns the run around a routine: prepares the backend, runs the routine, then leaves the tip as the routine's exit policy says and restores the protection, even after a panic. | 04:107-112 |
| Event bus | Receives every handle operation and the routine's own events; observers subscribe to it to write the log, print to the console and feed the workbench. | 04:132-137 |
| Log | The file one run leaves: its configuration, every event and the outcome, enough to reconstruct what was run with which numbers. | 04:135-136, 04:140-149 |

38 entries, all in canonical forms (decisions D7 to D13). TCP is expanded in the body (D13) but has no row; add one if the glossary should list every abbreviation. Classifier and analyzer are left out (04:177-186; not consulted by tip preparation); add them if ch8 keeps leaning on them.

Inserted after `tab:config` in src/A_appendix/default.typ as below. The
`#show figure.where(kind: table): set block(breakable: true)` rule at A:47
already applies to it, and `todo` and `flex-caption` are already imported.

```typst
#figure(
  table(
    columns: (auto, 1fr),
    align: (left, left),
    table.header[Term][Meaning],
    table.cell(colspan: 2, fill: luma(240))[Instrument and tip],
    [$Delta f$, frequency shift], [shift of the oscillating tip's frequency on a qPlus sensor, proportional to the average tip-sample force gradient; read after every pulse (@sec:foundations)],
    [qPlus sensor], [force sensor whose frequency shift $Delta f$ reports the tip-sample interaction],
    [SPM], [scanning probe microscopy: resolving a surface with a sharp tip close enough to interact with it, through a tunnelling current or through force],
    [STM], [scanning tunnelling microscopy; on a relatively clean surface, its feedback sets similar tunnelling conditions, and so a similar separation, from tip to tip],
    [NC-AFM], [non-contact atomic force microscopy; with STM, what the instrument of the counted runs is built for (@sec:validation)],
    [PLL], [phase-locked loop; follows the frequency shift up to the limits of its range],
    [Z-controller], [held during a pulse, switched back on to land the tip; has a current setpoint #todo[inferred from use; the text never says what it is]],
    [safe-tip protection], [the Nanonis controller's protection that retracts the tip when the current exceeds a threshold, $1$ nA by default; off during a run except while the tip is backed off],
    [apex], [its geometry and composition, not the instrument, set what the tip resolves (@sec:apex) #todo[the text never says what the apex is]],
    [blunt, sharp, stable], [the three apex states: sharp when $Delta f$ lies inside the sharp window, blunt otherwise, stable when a sharp tip keeps its $Delta f$ through the stability test],
    table.cell(colspan: 2, fill: luma(240))[Routine],
    [sharp window], [configured interval of $Delta f$, bounds included, inside which a tip counts as sharp],
    [bias pulse], [pulse of the bias, $50$ ms by default, fired with the Z-controller on hold; reshapes the apex through the field at it],
    [pulse strategy], [fixed, stepping or linear: the rule that chooses the next pulse voltage (@sec:pulse)],
    [clamp], [configured $Delta f$ interval below the sharp window over which the linear strategy raises the voltage with distance from the window],
    [cycle], [one bias pulse, a move to a fresh site, and a $Delta f$ reading],
    [conditioning loop], [the whole repeat of cycles, confirmation readings and, optionally, the stability test, until a tip holds through them],
    [fresh site], [place on the sample away from the spot the last pulse modified],
    [coarse step], [one step of the coarse motor; a move to a fresh site takes one per lateral axis by default],
    [coarse Z retract], [coarse steps of the tip away from the surface in Z; part of a move to a fresh site, and two steps after the final withdrawal by default],
    [calibrated approach], [approach, back off $50$ nm, centre the PLL's frequency shift, then land again by switching the Z-controller on],
    [landing], [the tip back in feedback after an approach; counts once the current is within $50 %$ of the setpoint and has stopped scattering and drifting],
    [landing gate], [the criterion that decides when a landing counts; gives up with a warning after $30$ s],
    [reading], [batch of samples from the data stream, $100$ by default, judged by its mean (@sec:measurement)],
    [noise gate, drift gate], [the measurement gates: checks on a reading's standard deviation and on the slope of a linear fit through it; a batch failing either is retried, then used anyway],
    [railed reading], [reading at the limit of the PLL controller's range, $plus.minus 76.29$ Hz in the counted runs; passes both measurement gates],
    [confirmation readings], [three further readings, each at a fresh site, that a tip inside the sharp window must keep inside it],
    [stability test], [bias sweeps while scanning; the tip is stable if $Delta f$ before and after differ by at most a tolerance, $0.2$ Hz by default],
    [maximum-voltage pulse], [pulse at the strategy's maximum voltage after a failed stability test, with the tip still engaged],
    [run], [one execution of the routine; it ends in one of four outcomes: completed, cycle budget reached, time budget exhausted, or stopped by the operator (@sec:outcomes)],
    [cycle budget, time budget], [the run limits, unset for none; an approach is bounded separately by the approach timeout],
    table.cell(colspan: 2, fill: luma(240))[Framework],
    [routine], [plain Rust struct implementing the `Routine` interface; owns the control flow],
    [controller interface], [`SpmController`, the one interface a routine targets to reach the instrument (@sec:controller-interface)],
    [backend], [implementation of the controller interface; reports its capabilities, and an operation needing a missing one fails before any command reaches the instrument],
    [mock backend], [backend without an instrument: scriptable $Delta f$ response, simulated Z-controller, injectable faults, recorded calls],
    [subsystem handle], [the only route to an operation; obtaining one checks the backend's capabilities, and every operation through it reaches the event bus],
    [harness], [owns the run around a routine: prepares the backend, runs the routine, leaves the tip as its exit policy says and restores the protection, even after a panic (@sec:harness)],
    [event bus], [receives every handle operation and routine event; observers write the log, print to the console and feed the workbench],
    [log], [file one run leaves, with its configuration, every event and the outcome; enough to reconstruct the run (@sec:events)],
  ),
  caption: flex-caption([
    Terms and abbreviations of this report, each with the section that
    introduces it where one does.
  ], [Terms and abbreviations]),
) <tab:glossary>
```

The appendix lead-in mentions it alongside the data types and configuration
fields.
