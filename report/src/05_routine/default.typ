#import "/report.typ": flex-caption
#import "/lib.typ": todo
#import "fig_state-machine.typ": tip-prep-fsm
#import "fig_cycle.typ": cycle-timeline

// Sources, unless a comment says otherwise: rusty-tip
// src/tip_prep/runner.rs (the routine), src/tip_prep/pulse_state.rs (voltage
// strategies), src/config.rs and src/controller_types.rs (defaults),
// src/action/z_controller.rs (calibrated approach), src/action/signals.rs
// (stable read). Where docs/tip-prep/*.md disagree with these, the code wins.

= The tip-preparation routine <sec:routine>

The routine conditions a tip as an operator does, by pulsing it and judging the
result, but never assumes what a pulse has done. A bias pulse changes the apex
unpredictably, so a fixed pulse sequence cannot know when to stop or whether it
has made the tip worse. The routine instead measures the frequency shift
$Delta f$ after every pulse and chooses its next step from it.

These decisions form a state machine over three apex states: blunt, sharp and
stable (@fig:fsm). @sec:apex discusses their physical meaning. A blunt tip is
pulsed and moved to a fresh site until $Delta f$ falls inside a configured
sharp window. A sharp tip must hold that window at several sites, then survive
bias sweeps while scanning. It either passes as stable, which ends the run, or
returns to blunt. A run starts with one reading after the first approach, so
an already sharp tip goes straight to these checks.

#figure(
  tip-prep-fsm(),
  caption: flex-caption([
    State machine of the routine. Each state selects a loop, and every loop
    ends in a $Delta f$ reading that decides the next transition.
  ], [State machine of the tip-preparation routine]),
) <fig:fsm>

The sections below follow one pass through the loop: the pulse and the move
off its site, the measurement, the two criteria classifying the tip, and how a
run ends.

== Bias pulses and pulse strategies <sec:pulse>

Each cycle (@fig:cycle) opens with a bias pulse, $50$ ms long by default,
applied with the Z-controller on hold so that it does not react. After a $1$ s settling time,
the tip is withdrawn, stepped laterally with the coarse motors and
re-approached. Only then is $Delta f$ measured. The tip leaves the pulse site
as fast as possible, since further interaction with the freshly modified spot
can change the apex again. The default of one coarse step in each direction
leaves the pulse debris behind while adding little creep for the re-approach to
land on.

#figure(
  cycle-timeline(),
  caption: flex-caption([
    One cycle of the routine, from the pulse to the $Delta f$ reading, with the
    configured pulse and settling time and otherwise the median durations of
    the counted runs (@sec:hardware-results); $tilde.op$ marks a phase whose
    length a gate decides. These runs stepped three coarse
    steps per axis and waited a further $1$ s after landing. Widths are not to
    scale.
  ], [One cycle of the tip-preparation routine]),
) <fig:cycle>

One of three pulse strategies, set in the run's configuration, chooses the next
pulse voltage:

- *Fixed.* The same voltage every cycle. The reading decides only whether to
  keep pulsing, never how hard.
- *Stepping.* The voltage starts at the lower end of a configured range,
  steps up while $Delta f$ stops rising and drops back once it rises again. It
  was not used on the instrument (@sec:hardware-results).
  // Rise: more than a threshold over the mean since the last change; stall: a
  // configured number of cycles; step: a fixed fraction of the range, capped.
- *Linear.* Within a configured $Delta f$ interval, the measured $Delta f$
  maps linearly onto the voltage range. The interval's lower end gives the
  lower voltage. Outside the interval the maximum voltage applies.
  #todo[The mapping gives the gentlest pulse to the most negative $Delta f$
    in the interval and the hardest near $0$ Hz. Is that the intent, and what
    is the reasoning?]

#todo[The scaffold asks what each strategy assumes about how the apex
  responds. I have the behaviour from the code but no source for the physical
  rationale.]

Each strategy fixes a polarity. Optionally, every $n$-th pulse fires at the
opposite polarity, on a fixed period.
// The config key is `random_polarity_switch`, but the code is periodic:
// `pulse_count.is_multiple_of(switch_every_n_pulses)`, pulse_state.rs:84.

== Measurement validation <sec:measurement>

No single $Delta f$ value from the Nanonis controller is trusted on its own. A
reading is a batch of samples from the Nanonis controller's data stream
(@sec:message-format), $100$ by default. At a $1$ kHz stream rate, such a batch
takes a tenth of a second. Its value is the batch mean, believed only once the
batch passes two gates. A noise gate checks its standard deviation, $1.5$ Hz
by default, and a drift gate the slope of a linear fit through it, $0.5$ Hz/s
by default. A batch failing either is retried after waits of $100$, $200$ and
$400$ ms.
// signals.rs:207, backoff_ms = 100 * 2^attempt, with read_retry_count = 3.

The gates delay a reading rather than veto it. A batch still failing after the
last retry is used anyway, logged with a warning and marked unstable in the log
(@sec:events). A run on a persistently noisy tip thus continues on the mean of
its last batch. Both thresholds are set per run and can be loosened for
noisier tips. The gates judge how a batch varies, not where it lies, which
leaves the blind spot of @sec:limitations.

== Sharpness and stability criteria <sec:criteria-applied>

A tip counts as sharp when $Delta f$ lies inside the configured sharp window,
bounds included. The window is a run parameter, not a routine constant.
@tab:run-params lists the values used.
#todo[How the window bounds were arrived at: no source yet.]

One reading inside the window could be luck: a favourable site or a metastable
apex. The routine therefore repositions and measures three more times. Any
reading outside the window sends it back to pulsing, and the next voltage is
chosen from that reading. The three confirmation readings are fixed, not
configured.

Sharp is not yet enough: an apex can rearrange under field stress. The
stability test takes the last confirmation reading as baseline. Then, for each
configured polarity, it moves to a fresh site and approaches. It starts a
continuous scan at reduced speed ($5$ nm/s by default) and steps the bias from
the largest magnitude of a configured range towards the smallest. With the
defaults, this is $1000$ steps of $200$ ms from $2$ V down to $0.01$ V, about
$200$ s per polarity, positive then negative. The tip is then withdrawn,
re-approached at the initial bias and measured again. Every sweep starts at a
fresh site, so baseline and final reading come from different sites. The test
therefore compares the apex across sites as well as across the sweep.

If the two readings differ by at most a configured tolerance, $0.2$ Hz by
default, the tip is stable and the run complete. Otherwise, the routine fires a
pulse at the strategy's maximum voltage (for the fixed strategy, its only
voltage). It then resets the strategy to its starting voltage and returns to
pulsing. This pulse fires with the tip still engaged from the final reading,
because a pulse acts through the field at the apex. That field exists only near
the surface, so a pulse fired withdrawn would reshape nothing. With the
stability test switched off, a confirmed sharp tip ends the run.

== Termination conditions and safety <sec:outcomes>

A run ends in one of four outcomes, none of them an error: completed, cycle
limit reached, time budget exhausted, or stopped by the operator. The time
budget starts after the first approach, before the initial reading, so a
stability test on a tip that arrives sharp already counts against it. Errors
are reserved for what the routine cannot handle, such as an approach
overrunning its time budget or a tripped safe-tip protection.

Every approach in the routine is a calibrated approach. The tip is approached
and backed off $50$ nm from where it landed, and the PLL's frequency shift is
centred there. The tip is then landed again by switching the Z-controller back
on. A landing counts once the tunnelling current is within $50 %$ of the
setpoint and has stopped scattering and drifting. This criterion replaces fixed
settling times. A landing not settled after $30$ s is taken as done, with a
warning.

The Nanonis controller's safe-tip protection retracts the tip when the current
exceeds a threshold, $1$ nA by default. A pulse is a deliberate current spike
that would trip it every cycle. The routine therefore switches it off for the
run, and on only while the tip is backed off during a calibrated approach. Its
status is checked after each step of that backed-off phase. A trip aborts the
run rather than approaching again into whatever caused it. The instrument has
already retracted the tip, and the check ensures the software never undoes
that.

However a run ends, the tip is withdrawn and the coarse motor backs off two
steps, since a withdrawal alone leaves the tip at the top of the piezo range
within reach of the surface. The safe-tip settings are also restored to their
pre-run values. A sweep likewise restores the scan properties, scan speed and
bias however it ends. Both rest on the harness (@sec:harness).
