= Outlook <sec:outlook>

// The framing of this chapter, the toolbox argument and the line-wise
// criterion are Martin's vision, settled in the session of 2026-11-09.
// Existing pieces: limits file rusty-tip src/control/limits.rs:1-33; control
// server src/control/mod.rs:1-18, Request::acts() false for every request;
// operating points src/operating_point.rs; drift routine src/drift.rs;
// CuOx-row detector src/analyzer/cuox_rows.rs; tilt compensation does not
// exist. References checked on 2026-11-09 against Crossref (boiko2023,
// mandal2025), the arXiv API (cheng2026) and the Anthropic pages (mcp2024,
// mhs2026).

The routine of @sec:routine is not only a step towards reliable automated tip functionalization; it is the first application of an automation framework designed to carry most operating procedures of a scanning probe microscope.
As routines are added and refined, the framework is where their stability and safety can grow once, for all of them.

The harness is the place for that growth.
Guards that today live in one routine, such as the safe-tip handling of @sec:outcomes, can become harness policy that refuses an unsafe sequence before it reaches the instrument.
Value limits are a first piece: the control server already loads an operator-written limits file, which bounds the bias, the pulse voltage, the coarse steps and the Z-controller setpoint that a request may ask for.
Sequence limits need the internal model of the instrument that the deleted engine of @sec:poc-lessons carried, since a caller without a compiler behind it can only be checked at run time.
The log allows a second kind of growth: because every run can be reconstructed from it, parameter sweeps can run unattended, and a routine is improved by measuring it rather than by reasoning about it.

A problem solved once on the harness is solved for every routine and every front end.
Operating points and drift compensation exist as tools of the workbench, the CuO#sub[x]-row detector exists as an analyzer, and tilt compensation is planned.
For an operator this is one workbench instead of a script per task.
For an agent it is a set of tools with defined arguments, limits and a log.
Language-model agents already run experiments and operate instruments, imperfectly @boiko2023 @mandal2025; standards for giving them tools and for reaching laboratory hardware are being written @mcp2024 @mhs2026.
Such agents have also conditioned STM tips end to end after a brief apprenticeship, reaching their limits where the effect of an action could not be observed directly or the agent's picture of the instrument did not contain the state that had changed @cheng2026.
Those are the two things a framework like this one supplies around a routine: a measurement discipline that never assumes what a pulse has done (@sec:routine), and a harness in which the instrument's state can be modelled once, for every caller (@sec:poc-lessons).
The read-only half of such access exists: the control server answers requests from scripts and agents as JSON over a local socket, so that a run can be analysed in few steps and without risk to the tip.
The acting half, routed through the same handles as a routine, does not exist yet and would need the model of the instrument named above.
As agents improve, a toolbox of safe, defined operations gains value rather than losing it.
A second backend remains the test of whether a routine written here runs elsewhere (@sec:architecture-eval).

The criterion is the next thing to change.
Defined terminations such as CO @gross2009 or CuO#sub[x] @wiesener2024 require judging a structure in an image, not a single value, and so does STM, where no frequency shift is available.
The classifier boundary of @sec:analyzers already carries frames to a model and its verdict back; what is missing is a trained model and the labelled frames to fit it.
A classifier that depends less on the patterns of a particular surface can use what is known about it instead: step heights, lattice spacings, the agreement of forward and backward pass, the contrast.
Operators judge this way from a few scan lines, and a classifier over a rolling window of scan lines has identified the tip state from a small fraction of an image @gordon2020.
Judging line by line is hard, but it is the way towards a criterion that runs while scanning and reports a confidence rather than a verdict per frame.
A CuO#sub[x] termination, which our laboratory needs, would be judged two ways: from the contrast of its rows in a line, and from the image, as Auto-CO-AFM does for CO tips @alldritt2022 and as the chemically selective contrast of @wiesener2024 allows.
Beyond judging the tip, the same logs are the dataset from which pulse amplitude, polarity and timing can be optimized offline and ultimately learned @alldritt2022 @rashidi2018.
All of this builds on the harness, the log and the classifier boundary, and should integrate into an operator's workflow more reliably than standalone scripts would.
