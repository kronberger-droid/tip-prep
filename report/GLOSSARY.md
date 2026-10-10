# Glossary for the tip-prep report (enforce exactly)

| Concept | Use | Replace these variants |
|---|---|---|
| one accepted Δf value (mean of a batch of samples) | reading; "confirmation readings" | read(s) as a noun, measurement, value (when meaning this). Exception: chapter 6 "Not every accepted reading was a measurement" is a deliberate contrast and stays. "measurement" stays where it is generic (chapter 4: the store, analyzers turning a measurement into a decision). |
| the pulse fired at the tip | bias pulse (later just "pulse") | voltage pulse |
| fixed / stepping / linear | pulse strategy | voltage strategy. The chapter-5 heading "Pulse application and voltage strategies" becomes "Bias pulses and pulse strategies" (keep its label). |
| interval of Δf counting as sharp | sharp window, window | "bounds" only for its two edges |
| the whole test with bias sweeps | stability test | stability check, stability sweep (as name of the test) |
| one bias sweep inside that test | sweep, bias sweep | |
| the pulse after a failed stability test | maximum-voltage pulse | max pulse |
| location on the sample surface | site; "fresh site" | position(s) (in that sense), new site, fresh surface. Keep "Z home position" and chapter-3 "matched by position". |
| microscope + Nanonis controller as a whole | the instrument; "on the instrument" | microscope, the machine; "on hardware"/"hardware evidence"/"real hardware" when meaning the real instrument. "hardware" stays only in the generic sense: "hardware abstraction", "hardware that must be restored", "hardware backend". |
| the vendor's control system | the Nanonis controller | bare "the controller" when it means this |
| an implementation of the controller trait | backend (the Nanonis backend, the mock backend / the mock) | "a controller", bare "the controller" when it means this. The trait itself: "the controller trait" (`SpmController`). |
| Nanonis current feedback | Z-controller | feedback loop (when it means the Z-controller). In the mock: "a simulated Z-controller". |
| phase-locked loop | spell out "phase-locked loop (PLL)" once, at its first use in chapter 4; "PLL" everywhere after that, in chapters 4-8 | bare "loop" for the PLL |
| the routine's repeated cycle | loop, pulse loop, conditioning loop | |
| a generic PI controller (chapter 3, slope encoding) | feedback controller | |
| protocol header + body | message; "request and response messages" | frame (in chapter 3 and its figure caption) |
| one sample set on the data-logging port | record | frame |
| a grabbed scan image | frame (`Frame`) | |
| continuous samples on the logging port | data stream | data logging channel; bare "stream" at the first mention in a section |
| the publish/subscribe mechanism | event bus | event stream |
| the file written for one run | the log, the run's log | event stream |
| one execution of a routine | run | |
| `Session` / `Job` software concepts (chapter 4) | session, job | session in any other sense: chapter 6 "taken in separate sessions" -> "taken on three separate days"; outlook "recorded sessions" -> "recorded runs" |
| the automation code | routine | procedure (except Tewari's "defined procedure" and generic manual practice) |
| the person at the microscope | operator | user (chapter 4 'stopped by user' -> 'stopped by the operator') |
| the fail-safe of the controller | safe-tip protection (or "the protection" within one paragraph) | tip protection |
