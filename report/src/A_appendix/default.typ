#import "/report.typ": flex-caption
#import "/lib.typ": todo

= Reference tables <apx:reference>

The data types of the message format of @sec:interface in full, and every
configuration field that shapes a run with its default, so that a run in
@sec:validation can be reproduced from the configuration its log records. Both
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
    R14718), which announces thirteen and lists these fourteen. "Usually" is the specification's own word: the
    signature of each command says which argument carries the length.
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
    [`safe_tip_threshold`], [$1$ nA], [current at which safe-tip retracts],
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
    [`approach_timeout_ms`], [$600$ s], [budget of an approach from a full withdraw],
    [`reposition_approach_timeout_ms`], [$300$ s], [budget of the approach inside a reposition],
    [`exit_retract_steps`], [$2$], [coarse Z steps back after the final withdraw],
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
