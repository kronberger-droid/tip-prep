# Glossary for the tip-prep report (enforce exactly)

`prose-glossary.md` holds the locked decisions (D7 to D13) with their findings;
this table is the short form to edit against. The reader-facing glossary is
`tab:glossary` in the appendix.

| Concept | Use | Replace these variants |
|---|---|---|
| a batch of samples from the data stream, judged by its mean | reading; "confirmation readings" | read(s) as a noun, measurement, value (when meaning this); "reading" for the mean alone. Exception: chapter 6 "Not every accepted reading was a measurement" is a deliberate contrast and stays. "measurement" stays where it is generic (chapter 4: the store, analyzers turning a measurement into a decision). "reading" in the sense of interpretation becomes "interpretation". |
| reading at the limit of the PLL controller's range | railed reading (introduced in chapter 6) | reading at the limit, edge of the range |
| the noise and drift checks on a reading | the measurement gates; noise gate, drift gate | bare "the gates", "both gates" where the landing gate could be meant |
| the check that a landing counts | landing gate | "this criterion" |
| the pulse fired at the tip | bias pulse (later just "pulse") | voltage pulse |
| fixed / stepping / linear | pulse strategy | voltage strategy. The chapter-5 heading "Pulse application and voltage strategies" becomes "Bias pulses and pulse strategies" (keep its label). |
| interval of Δf counting as sharp | sharp window, window | "bounds" only for its two edges |
| blunt / sharp / stable | apex state | tip state |
| one pulse, move to a fresh site and Δf reading | cycle | pulse loop |
| the whole repeat until a tip holds | conditioning loop | conditioning cycle; "loop" for one state's steps (say "sequence of steps") |
| run limits | cycle budget, time budget | cycle limit, time limit |
| the limit on one approach | approach timeout | time budget, budget of an approach |
| the whole test with bias sweeps | stability test | stability check, stability sweep (as name of the test) |
| one bias sweep inside that test | sweep, bias sweep | |
| the pulse after a failed stability test | maximum-voltage pulse | max pulse |
| location on the sample surface | site; "fresh site" | position(s) (in that sense), new site, fresh surface. Keep "Z home position" and chapter-3 "matched by position". |
| lateral coarse move | coarse step, "per lateral axis" | "per axis", "in each direction" |
| coarse move away from the surface | coarse Z retract | coarse retract, Z retract, "the coarse motor backs off" |
| pulling the tip back with the Z-piezo | withdrawal (noun), withdraw (verb) | withdraw as a noun |
| microscope + Nanonis controller as a whole | the instrument; "on the instrument" | microscope, the machine; "on hardware"/"hardware evidence"/"real hardware" when meaning the real instrument. "hardware" stays only in the generic sense: "hardware abstraction", "hardware that must be restored", "hardware backend". |
| the vendor's control system | the Nanonis controller | bare "the controller" when it means this |
| `SpmController` | the controller interface | controller trait, the trait. "interface" is reserved for this and the `Routine` interface. |
| an implementation of the controller interface | backend (the Nanonis backend, the mock backend / the mock) | "a controller", bare "the controller", "the Nanonis client" when it means the backend |
| nanonis-rs | the client, the Nanonis client; chapter 3 "The instrument protocol client" | "interface" for it; "TCP interface" becomes "TCP protocol" |
| the graphical tool host | the workbench (first use "a graphical workbench") | graphical interface, GUI |
| where frames go to a model and verdicts come back | classifier boundary | classifier stack, side, transport, interface |
| Nanonis current feedback | Z-controller | feedback loop (when it means the Z-controller). In the mock: "a simulated Z-controller". |
| phase-locked loop | spell out "phase-locked loop (PLL)" once, at its first use in chapter 4; "PLL" everywhere after that, in chapters 4-8 | bare "loop" for the PLL; "PLL loops" (say "PLLs") |
| protocol header + body | message; "request and response messages" | frame (in chapter 3 and its figure caption) |
| one sample set on the data-logging port | record | frame |
| one item in a run's log | log entry | record |
| a grabbed scan image | frame (`Frame`) | |
| continuous samples on the logging port | data stream | data logging channel; bare "stream" at the first mention in a section |
| the publish/subscribe mechanism | event bus | event stream |
| the file written for one run | the log, the run's log | event stream |
| one execution of a routine | run | |
| how a run ends | outcome | ending, endings |
| `Session` / `Job` software concepts (chapter 4) | session, job | session in any other sense: chapter 6 "taken in separate sessions" -> "taken on three separate days"; outlook "recorded sessions" -> "recorded runs" |
| the automation code | routine | procedure (except Tewari's "standardized procedure" and generic manual practice) |
| prior art for @tewari2017 / the learned methods | standardized procedure(s); machine-learning-assisted | defined procedure(s); machine-learning-driven |
| the goal state of preparation | well-prepared tip (abstract keeps "well-functionalized") | good tip |
| the end of the tip | tip, apex | probe, except inside "scanning probe" |
| the person at the microscope | operator | user (chapter 4 'stopped by user' -> 'stopped by the operator') |
| the fail-safe of the controller | safe-tip protection (or "the protection" within one paragraph) | tip protection, bare "safe-tip" |
| CuO_x | CuO#sub[x] | CuOx |
| abbreviations | "long form (ABBR)" at first body use: SPM (introduction), STM (chapter 2), TCP (introduction), PLL (chapter 4), NC-AFM (chapter 6); the abstract keeps its own text. JSON, HTTP, npy, I/O stay unexpanded. | nc-AFM |
