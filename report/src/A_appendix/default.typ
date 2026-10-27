#import "/report.typ": flex-caption
#import "/lib.typ": todo

= Reference tables <apx:reference>

This appendix lists the data types of the message format of @sec:interface in
full, and every configuration field that shapes a run, with its default, so
that a run in @sec:validation can be reproduced from the configuration its log
records. A glossary of the report's terms and abbreviations follows. All three
are here because nobody reads them in sequence.

#figure(
  table(
    columns: 3,
    align: (left, left, left),
    table.header[Type][Encoding][Length],
    [string], [one byte per character], [prefixed as a 32-bit integer; fixed 32 bytes for a command name],
    [int], [32-bit signed, big-endian], [4 bytes],
    [unsigned int16], [16-bit unsigned, big-endian], [2 bytes],
    [unsigned int32], [32-bit unsigned, big-endian], [4 bytes],
    [float32], [single precision, big-endian], [4 bytes],
    [float64], [double precision, big-endian], [8 bytes],
    [1D array string], [strings, each length-prefixed], [element count and byte size sent before it],
    [1D array int], [32-bit signed integers], [element count usually sent before it],
    [1D array unsigned int8], [8-bit unsigned integers], [element count usually sent before it],
    [1D array unsigned int32], [32-bit unsigned integers], [element count usually sent before it],
    [1D array float32], [single-precision floats], [element count usually sent before it],
    [1D array float64], [double-precision floats], [element count usually sent before it],
    [2D array float32], [single-precision floats, by row], [rows and columns usually sent before it],
    [2D array string], [strings, each length-prefixed], [rows and columns usually sent before it],
  ),
  caption: flex-caption([
    The data types of the Nanonis TCP protocol (specification revision
    R14718); the specification announces thirteen types and lists these
    fourteen. "Usually" is the specification's own word: the signature of each
    command says which argument carries the length.
  ], [Data types of the Nanonis TCP protocol]),
) <tab:data-types>

// Defaults from rusty-tip main (7976b24): src/config.rs (`default_*` and the
// `Default` impls of DataAcquisitionConfig, TipPrepConfig, TimingConfig,
// SignalStabilityConfig), src/controller_types.rs (StabilityConfig,
// PulseMethod) and src/action/z_controller.rs (DEFAULT_APPROACH_TIMEOUT_MS).
// Connection, logging and console settings are left out: they do not change
// what a run does to the tip.
#let section(name) = table.cell(colspan: 3, fill: luma(240), raw("[" + name + "]"))

#show figure.where(kind: table): set block(breakable: true)
#figure(
  table(
    columns: (auto, auto, 1fr),
    align: (left, left, left),
    table.header[Field][Default][Meaning],
    section("data_acquisition"),
    [`sample_rate`], [$1000$ Hz], [rate of the streamed signals],
    [`stable_signal_samples`], [$100$], [samples per reading and per landing-gate batch],
    section("tip_prep"),
    [`sharp_tip_bounds`], [$-2$ to $0$ Hz], [sharp window],
    [`max_cycles`], [$10000$], [cycle budget; unset for none],
    [`max_duration_secs`], [$12000$ s], [time budget; unset for none],
    [`initial_bias_v`], [$-0.5$ V], [bias before the first approach],
    [`initial_z_setpoint_a`], [$100$ pA], [Z-controller setpoint before the first approach],
    [`safe_tip_threshold`], [$1$ nA], [current at which safe-tip protection retracts the tip],
    [`z_controller_preset`], [none], [Z-controller preset written before the first approach],
    section("tip_prep.timing"),
    [`pulse_width_ms`], [$50$ ms], [pulse length],
    [`post_pulse_settle_ms`], [$1$ s], [wait after a pulse],
    [`reposition_steps`], [$1$, $1$], [coarse steps in x and y per reposition],
    [`post_approach_settle_ms`], [$0$ ms], [extra wait after a landing],
    [`post_reposition_settle_ms`], [$0$ ms], [extra wait after a reposition],
    [`landing_tolerance`], [$0.5$], [landing gate: current within this fraction of the setpoint],
    [`landing_timeout_ms`], [$30$ s], [landing gate gives up, with a warning],
    [`buffer_clear_wait_ms`], [$500$ ms], [wait after clearing the stream buffer, before the first reading],
    [`approach_timeout_ms`], [$600$ s], [approach timeout from a full withdrawal],
    [`reposition_approach_timeout_ms`], [$300$ s], [approach timeout inside a reposition],
    [`exit_retract_steps`], [$2$], [steps of the coarse Z retract after the final withdrawal],
    [`status_interval`], [$10$], [cycles between status lines in the log],
    section("tip_prep.signal_stability"),
    [`max_std_dev_hz`], [$1.5$ Hz], [noise gate of a reading],
    [`max_slope_hz_per_s`], [$0.5$ Hz/s], [drift gate of a reading],
    [`read_retry_count`], [$3$], [retries before a failing reading is used anyway],
    section("tip_prep.stability"),
    [`check_stability`], [on], [run the stability test],
    [`stable_tip_allowed_change`], [$0.2$ Hz], [tolerance between baseline and final reading],
    [`bias_range`], [$0.01$ to $2$ V], [magnitudes the sweep steps through],
    [`bias_steps`], [$1000$], [steps per sweep],
    [`step_period_ms`], [$200$ ms], [time per step],
    [`polarity_mode`], [both], [sweep polarities, positive then negative],
    [`scan_speed_m_s`], [$5$ nm/s], [scan speed during a sweep],
    section("pulse_method"),
    [`type`], [stepping], [fixed, stepping or linear (@sec:pulse)],
    [`voltage_bounds`], [$2$ to $6$ V], [gentlest and hardest pulse],
    [`voltage_steps`], [$4$], [stepping: steps across the range],
    [`cycles_before_step`], [$2$], [stepping: cycles without progress before a step],
    [`threshold_value`], [$0.1$ Hz], [stepping: rise that counts as progress],
    [`polarity`], [positive], [polarity of the pulses],
    [`random_polarity_switch`], [off], [every $n$-th pulse at the opposite polarity],
  ),
  caption: flex-caption([
    Configuration fields that shape a run, with their defaults in rusty-tip.
    The fixed strategy takes a `voltage` and the linear one a `linear_clamp`,
    neither with a default; see @tab:run-params for the values the counted
    runs used.
  ], [Configuration fields and their defaults]),
) <tab:config>

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
    [Z-controller], [the Nanonis current feedback: holds the tunnelling current at its setpoint by moving the tip in Z; held during a pulse, switched back on to land the tip],
    [safe-tip protection], [the Nanonis controller's protection that retracts the tip when the current exceeds a threshold, $1$ nA by default; off during a run except while the tip is backed off],
    [apex], [end of the tip, whose atoms carry the short-range part of the tip-sample force; its geometry and composition, not the instrument, set what the tip resolves (@sec:apex)],
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
