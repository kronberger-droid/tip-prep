= The tip-preparation routine <sec:routine>

The procedure itself, and the reasoning behind each step.

A pulse changes the apex unpredictably, so the routine is built as a state
machine over three apex states: blunt, sharp and stable. A conditioning or
validation loop is selected by the current state, and each loop terminates in a
measurement of $Delta f$. Why an open-loop recipe cannot work, and a
measure-and-decide loop can.

== Measurement validation <sec:measurement>

A reading is a batch of stream samples that has to settle before the routine
believes it: a noise gate and a drift gate, with bounded retries when a batch
fails either.

== Pulse application and voltage strategies <sec:pulse>

The pulse, and why the tip is moved to fresh surface before the next
measurement rather than after it.

The voltage held fixed, scaled directly with $Delta f$, or stepped up after
repeated cycles without improvement and reset once the tip improves, with
polarity optionally alternated on a fixed period. What each strategy assumes
about how the apex responds.

== Sharpness and stability criteria <sec:criteria-applied>

The $Delta f$ window that counts as sharp and how its bounds were arrived at,
and why several in-bounds measurements at different positions are required
before the tip is classified as such.

Then the harder test: the bias swept through both polarities during slow
scanning, with the tip counting as stable only if $Delta f$ returns to its
initial value within tolerance. Otherwise a strong pulse resets it to blunt and
the loop starts again.

== Termination conditions and safety <sec:outcomes>

Completed, cycle limit, timeout and operator stop are all endings, not errors.
Withdrawal on every exit path, the safe-tip threshold underneath it, and scan
properties and bias restored however a sweep ends.
