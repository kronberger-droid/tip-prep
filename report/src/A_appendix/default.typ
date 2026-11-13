#import "/theme.typ" as th
#import "/report.typ": flex-caption
#import "/lib.typ": code-refs, code-url, todo

= Reference tables <apx:reference>

The four tables of this appendix are collected here because they are consulted, not read in sequence.
The configuration table lists every field that shapes a run, with its default, so that a run in @sec:validation can be reproduced from the configuration its log records.
The code reference gives, for each part of the framework this report names, the file and line that declare it at one fixed revision of rusty-tip, and is followed by listings of selected code.

== Data types of the message format <apx:data-types>

#figure(
  table(
    columns: 3,
    align: (left, left, left),
    table.header[Type][Encoding][Length],
    [string],
    [one byte per character],
    [prefixed as a 32-bit integer; fixed 32 bytes for a command name],

    [int], [32-bit signed, big-endian], [4 bytes],
    [unsigned int16], [16-bit unsigned, big-endian], [2 bytes],
    [unsigned int32], [32-bit unsigned, big-endian], [4 bytes],
    [float32], [single precision, big-endian], [4 bytes],
    [float64], [double precision, big-endian], [8 bytes],
    [1D array string],
    [strings, each length-prefixed],
    [element count and byte size sent before it],

    [1D array int],
    [32-bit signed integers],
    [element count usually sent before it],

    [1D array unsigned int8],
    [8-bit unsigned integers],
    [element count usually sent before it],

    [1D array unsigned int32],
    [32-bit unsigned integers],
    [element count usually sent before it],

    [1D array float32],
    [single-precision floats],
    [element count usually sent before it],

    [1D array float64],
    [double-precision floats],
    [element count usually sent before it],

    [2D array float32],
    [single-precision floats, by row],
    [rows and columns usually sent before it],

    [2D array string],
    [strings, each length-prefixed],
    [rows and columns usually sent before it],
  ),
  caption: flex-caption(
    [
      The data types of the Nanonis TCP protocol (specification revision R14718); the specification announces thirteen types and lists these fourteen.
      "Usually" is the specification's own word: the signature of each command says which argument carries the length.
    ],
    [Data types of the Nanonis TCP protocol],
  ),
) <tab:data-types>

== Configuration fields and their defaults <apx:config>

// Defaults from rusty-tip main (7976b24): src/config.rs (`default_*` and the
// `Default` impls of DataAcquisitionConfig, TipPrepConfig, TimingConfig,
// SignalStabilityConfig), src/controller_types.rs (StabilityConfig,
// PulseMethod) and src/action/z_controller.rs (DEFAULT_APPROACH_TIMEOUT_MS).
// Connection, logging and console settings are left out: they do not change
// what a run does to the tip.
// The shaded row that opens a group in the tables of this appendix.
#let group-row(body, cols: 3) = table.cell(colspan: cols, fill: th.grey(240), body)
#let section(name) = group-row(raw("[" + name + "]"))

#show figure.where(kind: table): set block(breakable: true)
#figure(
  table(
    columns: (auto, auto, 1fr),
    align: (left, left, left),
    table.header[Field][Default][Meaning],
    section("data_acquisition"), [`sample_rate`], [$1000$ Hz],
    [rate of the streamed signals], [`stable_signal_samples`], [$100$],
    [samples per reading and per landing-gate batch],
    section("tip_prep"),
    [`sharp_tip_bounds`],

    [$-2$ to $0$ Hz], [sharp window], [`max_cycles`],
    [$10000$], [cycle budget; unset for none], [`max_duration_secs`],
    [$12000$ s], [time budget; unset for none], [`initial_bias_v`],
    [$-0.5$ V], [bias before the first approach], [`initial_z_setpoint_a`],
    [$100$ pA],
    [Z-controller setpoint before the first approach],
    [`safe_tip_threshold`],

    [$1$ nA],
    [current at which safe-tip protection retracts the tip],
    [`z_controller_preset`],

    [none],
    [Z-controller preset written before the first approach],
    section("tip_prep.timing"),

    [`pulse_width_ms`], [$50$ ms], [pulse length],
    [`post_pulse_settle_ms`], [$1$ s], [wait after a pulse],
    [`reposition_steps`], [$1$, $1$], [coarse steps in x and y per reposition],
    [`post_approach_settle_ms`], [$0$ ms], [extra wait after a landing],
    [`post_reposition_settle_ms`], [$0$ ms], [extra wait after a reposition],
    [`landing_tolerance`],
    [$0.5$],
    [landing gate: current within this fraction of the setpoint],

    [`landing_timeout_ms`],
    [$30$ s],
    [time after which the landing gate gives up, with a warning],

    [`buffer_clear_wait_ms`],
    [$500$ ms],
    [wait after clearing the stream buffer, before the first reading],

    [`approach_timeout_ms`],
    [$600$ s],
    [approach timeout from a full withdrawal],

    [`reposition_approach_timeout_ms`],
    [$300$ s],
    [approach timeout inside a reposition],

    [`exit_retract_steps`],
    [$2$],
    [steps of the coarse Z retract after the final withdrawal],

    [`status_interval`], [$10$], [cycles between status lines in the log],
    section("tip_prep.signal_stability"), [`max_std_dev_hz`], [$1.5$ Hz],
    [noise gate of a reading], [`max_slope_hz_per_s`], [$0.5$ Hz/s],
    [drift gate of a reading], [`read_retry_count`], [$3$],
    [retries before a failing reading is used anyway],
    section("tip_prep.stability"),
    [`check_stability`],

    [on], [run the stability test], [`stable_tip_allowed_change`],
    [$0.2$ Hz], [tolerance between baseline and final reading], [`bias_range`],
    [$0.01$ to $2$ V], [magnitudes the sweep steps through], [`bias_steps`],
    [$1000$], [steps per sweep], [`step_period_ms`],
    [$200$ ms], [time per step], [`polarity_mode`],
    [both], [sweep polarities, positive then negative], [`scan_speed_m_s`],
    [$5$ nm/s], [scan speed during a sweep], section("pulse_method"),
    [`type`], [stepping], [fixed, stepping or linear (@sec:pulse)],
    [`voltage_bounds`], [$2$ to $6$ V], [gentlest and hardest pulse],
    [`voltage_steps`], [$4$], [stepping: steps across the range],
    [`cycles_before_step`],
    [$2$],
    [stepping: cycles without progress before a step],

    [`threshold_value`], [$0.1$ Hz], [stepping: rise that counts as progress],
    [`polarity`], [positive], [polarity of the pulses],
    [`random_polarity_switch`],
    [off],
    [every $n$-th pulse at the opposite polarity],
  ),
  caption: flex-caption(
    [
      Configuration fields that shape a run, with their defaults in rusty-tip.
      The fixed strategy takes a `voltage` and the linear one a `linear_clamp`, neither with a default; see @tab:run-params for the values the counted runs used.
    ],
    [Configuration fields and their defaults],
  ),
) <tab:config>

== Code reference <apx:code>

// Generated: scripts/code_refs.nu resolves every line at the pinned revision
// and writes data/code_refs.json, which `code()` in lib.typ reads as well.
#let code-rows = {
  let rows = ()
  let group = none
  for entry in code-refs.items {
    if entry.group != group {
      group = entry.group
      rows.push(group-row(group))
    }
    rows.push([#entry.term])
    rows.push(raw(entry.item))
    rows.push(link(code-url(entry.file, entry.line), raw(entry.file + ":" + str(entry.line))))
  }
  rows
}

#figure(
  table(
    columns: (1fr, auto, auto),
    align: (left, left, left),
    table.header[Term in this report][Item][File and line],
    ..code-rows,
  ),
  caption: flex-caption(
    [
      Where the parts of the framework and of the routine are declared in rusty-tip, on #raw(code-refs.rev) at commit #raw(code-refs.commit.slice(0, 7)).
      Each location links to that line in the repository at #link(code-refs.repo).
    ],
    [Code reference],
  ),
) <tab:code>

#let lst-ref(l) = ref(label("lst:" + l.label), supplement: none)
Listings #lst-ref(code-refs.listings.first()) to #lst-ref(code-refs.listings.last()) print code from that commit, chosen to show how what chapters @sec:framework[] and @sec:routine[] describe is modelled, not to document the library.
Each fragment is headed by its file and lines, which link to the repository; in an abridged one a `// ...` line stands for omitted lines, logging in the cycle and the other operations in the interface.

// Which code is printed, and what is cut from it, is the LISTINGS list in
// scripts/code_refs.nu.
#let fragment-head(f) = {
  let lines = str(f.first_line) + "-" + str(f.last_line)
  text(size: 7.5pt, fill: th.grey(90), {
    link(code-url(f.file, f.first_line, last: f.last_line), raw(f.file + ":" + lines))
    if f.abridged [, abridged]
  })
}
#let fragment-block(f) = block(
  width: 100%,
  breakable: false,
  stroke: 0.5pt + th.grey(160),
  inset: 6pt,
  align(left, {
    fragment-head(f)
    v(-0.3em)
    set par(leading: 0.45em)
    text(size: 7.5pt, raw(f.source, lang: "rust", block: true))
  }),
)
#show figure.where(kind: raw): set block(breakable: true)
#for l in code-refs.listings {
  let caption = eval(l.caption, mode: "markup")
  [#figure(
    kind: raw,
    supplement: [Listing],
    context if target() == "html" {
      // No stack in HTML: each fragment is a bordered div holding a `pre`.
      l.fragments.map(f => html.elem("div", attrs: (class: "fragment"), {
        html.elem("div", attrs: (class: "fragment-head"), fragment-head(f))
        raw(f.source, lang: "rust", block: true)
      })).join()
    } else {
      stack(spacing: 4pt, ..l.fragments.map(fragment-block))
    },
    caption: flex-caption(
      [#caption.],
      caption,
    ),
  ) #label("lst:" + l.label)]
}

== Terms and abbreviations <apx:glossary>

#figure(
  table(
    columns: (auto, 1fr),
    align: (left, left),
    // Definitions of the first group: qPlus sensor, NC-AFM and the PLL as
    // frequency detector from giessibl2019 (abstract; p. 8 for the fixed
    // prong; "frequency detector (PLL)" in the noise section); STM from
    // binnig1982; the Safe Tip feature and the Z-controller from the Nanonis
    // specification, nanonis-rs docs/tcp-protocol.md (SafeTip.*, ZCtrl.*).
    table.header[Term][Meaning],
    group-row(cols: 2)[Instrument and tip],
    [SPM],
    [scanning probe microscopy: the family of techniques that image a surface by scanning it with a sharp tip at a distance small enough for the two to interact (@sec:foundations)],
    [STM],
    [scanning tunnelling microscopy: SPM that measures the tunnelling current flowing between tip and sample at an applied bias @binnig1982],
    [NC-AFM],
    [non-contact atomic force microscopy: SPM that measures the tip-sample force with an oscillating force sensor in a noncontact mode; in the frequency-modulation variant used here, conservative forces shift the sensor's frequency @giessibl2019],
    [instrument],
    [the microscope together with its Nanonis controller @nanonis; the one of the counted runs is built for STM and NC-AFM (@sec:validation)],
    [qPlus sensor],
    [stiff quartz force sensor, originally a tuning fork with one prong fixed so that the other acts as a cantilever carrying the tip; it senses its own deflection through the piezoelectricity of quartz and allows STM and AFM in parallel @giessibl2019],
    [$Delta f$, frequency shift],
    [difference between the oscillation frequency of the sensor and its eigenfrequency, caused by the conservative part of the tip-sample force and proportional to the averaged force gradient (@sec:foundations); read after every pulse],
    [PLL],
    [phase-locked loop: the frequency detector that tracks the sensor's oscillation and outputs $Delta f$ @giessibl2019; it follows the frequency shift only up to the limits of its range],
    [bias],
    [voltage applied between tip and sample],
    [Z-controller],
    [the Nanonis feedback loop that regulates the tip height (Z); in the runs it holds the tunnelling current at its setpoint, is put on hold during a pulse and is switched back on to land the tip],
    [safe-tip protection],
    [the Nanonis controller's Safe Tip feature, which retracts the tip when the current exceeds a threshold, $1$ nA by default; off during a run except while the tip is backed off],
    [apex],
    [the end of the tip that faces the sample; its foremost atoms carry the short-range part of the tip-sample force, and its geometry and composition determine what the tip resolves (@sec:apex)],
    [blunt, sharp, stable],
    [the three apex states: sharp when $Delta f$ lies inside the sharp window, blunt otherwise, stable when a sharp tip keeps its $Delta f$ through the stability test],
    group-row(cols: 2)[Routine],
    [sharp window],
    [configured interval of $Delta f$, bounds included, inside which a tip counts as sharp (@sec:criteria-applied)],
    [bias pulse],
    [brief step of the bias to the pulse voltage, $50$ ms by default, applied with the Z-controller on hold; it reshapes the apex through the electric field at it (@sec:pulse)],
    [pulse strategy],
    [fixed, stepping or linear: the rule that chooses the next pulse voltage (@sec:pulse)],
    [clamp],
    [configured $Delta f$ interval below the sharp window over which the linear strategy raises the voltage with distance from the window],
    [cycle], [one bias pulse, a move to a fresh site, and a $Delta f$ reading],
    [conditioning loop],
    [the repetition of cycles, confirmation readings and, optionally, the stability test until a tip passes all of them],
    [fresh site],
    [place on the sample away from the spot the last pulse modified],
    [coarse step],
    [one step of the coarse motor; a move to a fresh site is made of them],
    [coarse Z retract],
    [coarse steps of the tip away from the surface in Z; part of a move to a fresh site, and the last step after the final withdrawal],
    [calibrated approach],
    [approach, back off $50$ nm, centre the PLL's frequency shift, then land again by switching the Z-controller on],
    [landing],
    [the state after an approach in which the Z-controller again holds the tunnelling current at its setpoint; it counts once the current is within $50 %$ of the setpoint and has stopped scattering and drifting (@sec:outcomes)],
    [landing gate],
    [the criterion that decides when a landing counts; after $30$ s without a settled landing it gives up with a warning],
    [reading],
    [batch of samples from the data stream, $100$ by default, judged by its mean (@sec:measurement)],
    [noise gate, drift gate],
    [the measurement gates: checks on a reading's standard deviation and on the slope of a linear fit through it; a batch failing either is retried, then used anyway],
    [railed reading],
    [reading at the limit of the PLL controller's range, $plus.minus 76.29$ Hz in the counted runs; passes both measurement gates],
    [confirmation readings],
    [three further readings, each at a fresh site, that a tip inside the sharp window must keep inside it],
    [stability test],
    [test in which the bias is swept while scanning; the tip is stable if $Delta f$ before and after differ by at most a tolerance, $0.2$ Hz by default (@sec:criteria-applied)],
    [maximum-voltage pulse],
    [pulse at the strategy's maximum voltage after a failed stability test, with the tip still engaged],
    [run],
    [one execution of the routine; barring an error, it ends in one of four outcomes: completed, cycle budget reached, time budget exhausted, or stopped by the operator (@sec:outcomes)],
    [cycle budget, time budget],
    [limits on the number of cycles and on the duration of a run, either of which can be left unset; an approach is bounded separately by the approach timeout],
    group-row(cols: 2)[Framework],
    [routine],
    [the automation code for one task, here tip preparation: a Rust type that implements the `Routine` interface and owns the control flow (@sec:harness)],
    [controller interface],
    [`SpmController`, the one interface a routine targets to reach the instrument (@sec:controller-interface)],
    [backend],
    [implementation of the controller interface; reports its capabilities, and an operation needing a missing one fails before any command reaches the instrument],
    [mock backend],
    [backend without an instrument: scriptable $Delta f$ response, simulated Z-controller, injectable faults, recorded calls],
    [subsystem handle],
    [the only route to an operation; obtaining one checks the backend's capabilities, and every operation through it reaches the event bus],
    [harness],
    [owns the run around a routine: prepares the backend, runs the routine, leaves the tip as its exit policy says and restores the protection, even after a panic (@sec:harness)],
    [event bus],
    [receives every handle operation and routine event; observers write the log, print to the console and feed the workbench],
    [log],
    [file one run leaves, with its configuration, every event and the outcome; enough to reconstruct the run (@sec:events)],
  ),
  caption: flex-caption(
    [
      Terms and abbreviations of this report, with the section that introduces each or the source that defines it.
    ],
    [Terms and abbreviations],
  ),
) <tab:glossary>
