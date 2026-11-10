# Extract the Δf trace of one or more runs into a small JSON the poster reads.
#
# `figures/convergence.typ` used to carry its numbers as hand-typed arrays. That
# is fine for a 10-point run and unworkable for a 295-point one, and it also puts
# the provenance in a comment where nothing checks it. This writes the traces plus
# their provenance to one file that Typst loads with `json()`, so the poster still
# builds with the data drive unplugged.
#
# Usage:
#     nu scripts/extract_trace.nu figures/traces.json LOG [LOG ...]
#
# Each read in the output is one `Get stable signal` result paired with the
# `Check tip state` verdict that followed it, so `df[i]` and `shape[i]` describe
# the same moment. Reads with no following state check are dropped.
#
# Every read also gets a `phase`, which is what lets the figure colour the
# stability check separately from the pulse loop:
#
#     loop        a read that follows a bias pulse, i.e. the conditioning loop
#     confirm     a read with no pulse since the previous one. `check_stability`
#                 opens with `confirm_sharp`, CONFIRMATION_READS reads that
#                 reposition but never pulse, so "no pulse since the last read"
#                 identifies them exactly
#     post_sweep  the first read after a `Check tip stability` action
#
# `stability` collects one entry per check that reached its sweeps, with the
# baseline (the last `confirm` read), the `post_sweep` read, and the verdict.
# `runner.rs::check_stability` computes that verdict as
# `|final - baseline| <= stable_tip_allowed_change`, so it is recomputed here
# rather than read out of the log: the per-sweep `TipState` in these files comes
# from an action that no longer exists in `rusty-tip`, and its `is_stable` flag
# does not agree with the loop's own behaviour. The tolerance is parsed off the
# action string, which prints it as a percentage but stores Hz, so "200.0% change
# allowed" is 2.0 Hz.
#
# The logs run to gigabytes, so they are never parsed as JSON. They are
# pretty-printed, and every field this needs sits alone on its own line at a
# known indentation, so `rg` pulls those lines out and the rest is text.

const PATTERNS = [
  '^    "action": '
  '^    "start_time": '
  '^        "stable_value": '
  '^        "shape": '
]
# Two log generations: `Pulse retract -4.0V` (Dec 2025) and `Bias pulse
# -8.000V` (2026). Matching only the first silently reported 0 pulses for every
# 2026 run, which is how a 36-pulse run looked like a 0-pulse one in the index.
const PULSE_RE = '^(?:Pulse retract|Bias pulse) (?<volts>-?[0-9.]+)V'
const SWEEP_RE = 'Check tip stability: bias sweep .*? from (?<from>-?[0-9.]+)V to (?<to>-?[0-9.]+)V \((?<steps>\d+) steps, (?<period>\d+)ms period, (?<change>[0-9.]+)% change allowed'
const BOUNDS_RE = 'bounds \((?<lo>[-0-9.e]+), (?<hi>[-0-9.e]+)\)'

# The value of a `"key": value,` line as text: key, quotes and comma stripped.
def field-value [] {
  $in | str trim | split row ": " -n 2 | get 1 | str trim -c "," | str trim -c '"'
}

# The lines of the log that matter, in order.
def field-lines [path: path] {
  let rg = (^rg -N ...($PATTERNS | each {|p| ["-e" $p] } | flatten) -- $path | complete)
  if $rg.exit_code > 1 {
    error make {msg: $"rg failed on ($path): ($rg.stderr)"}
  }
  $rg.stdout | lines
}

def extract [path: path] {
  mut reads = []
  mut shapes = []
  mut phases = []
  mut pulses = []
  mut bounds: any = null
  mut pending: any = null         # a stable_value waiting for its state check
  mut t_first: any = null
  mut t_last: any = null

  # Reset at every committed read: they describe what happened in the gap
  # between the previous read and this one.
  mut pulsed_since_read = true    # the first read of a run counts as loop
  mut swept_since_read = false
  mut sweeps = []                 # sweeps seen since the last read
  mut stability = []
  mut tolerance: any = null

  for line in (field-lines $path) {
    let s = ($line | str trim)
    if ($s | str starts-with '"action"') {
      let act = ($s | field-value)
      let pulse = ($act | parse -r $PULSE_RE)
      if ($pulse | is-not-empty) {
        $pulses = ($pulses | append ($pulse.0.volts | into float))
        $pulsed_since_read = true
      }
      let sweep = ($act | parse -r $SWEEP_RE)
      if ($sweep | is-not-empty) {
        $swept_since_read = true
        $sweeps = ($sweeps | append {
          from: ($sweep.0.from | into float)
          to: ($sweep.0.to | into float)
          steps: ($sweep.0.steps | into int)
          period_ms: ($sweep.0.period | into int)
        })
        $tolerance = (($sweep.0.change | into float) / 100.0)
      }
      if $bounds == null and ($act | str contains "Check tip state") {
        let b = ($act | parse -r $BOUNDS_RE)
        if ($b | is-not-empty) {
          $bounds = [($b.0.lo | into float) ($b.0.hi | into float)]
        }
      }
    } else if ($s | str starts-with '"start_time"') {
      let t = ($s | field-value)
      if $t_first == null { $t_first = $t }
      $t_last = $t
    } else if ($s | str starts-with '"stable_value"') {
      $pending = ($s | field-value | into float)
    } else if ($s | str starts-with '"shape"') {
      if $pending == null {
        continue                  # a sweep's own TipState, not a read
      }
      let phase = if $swept_since_read {
        "post_sweep"
      } else if $pulsed_since_read {
        "loop"
      } else {
        "confirm"
      }

      $reads = ($reads | append ($pending | math round -p 3))
      $shapes = ($shapes | append ($s | field-value))
      $phases = ($phases | append $phase)

      if $phase == "post_sweep" {
        # Baseline is the last `confirm` read before the sweeps.
        let prev = ($phases | drop 1 | enumerate | where item == confirm | get index)
        let baseline = if ($prev | is-empty) { null } else { $reads | get ($prev | last) }
        let final = ($reads | last)
        let change = if $baseline == null { null } else { ($final - $baseline) | math abs }
        $stability = ($stability | append {
          sweeps: $sweeps
          tolerance_hz: $tolerance
          baseline: $baseline
          final: $final
          change: (if $change == null { null } else { $change | math round -p 3 })
          passed: (if $change == null { null } else { $change <= $tolerance })
          baseline_index: (if ($prev | is-empty) { null } else { $prev | last })
          final_index: (($reads | length) - 1)
        })
      }

      $pending = null
      $pulsed_since_read = false
      $swept_since_read = false
      $sweeps = []
    }
  }

  {
    file: ($path | path basename)
    df: $reads
    shape: $shapes
    phase: $phases
    pulses: ($pulses | length)
    pulse_voltages: ($pulses | uniq | sort)
    sharp_bounds: $bounds
    stability: $stability
    start: $t_first
    end: $t_last
  }
}

def main [out: path, ...logs: path] {
  if ($logs | is-empty) {
    error make {msg: "usage: nu scripts/extract_trace.nu figures/traces.json LOG [LOG ...]"}
  }
  let runs = ($logs | each {|p|
    let r = (extract $p)
    let checks = (
      $r.stability
      | each {|c| $"($c.change) Hz vs ($c.tolerance_hz) Hz -> (if $c.passed { 'pass' } else { 'FAIL' })" }
      | str join ", "
      | default "none" --empty
    )
    let confirms = ($r.phase | where $it == confirm | length)
    print -e $"($r.file): ($r.df | length) reads, ($r.pulses) pulses, bounds ($r.sharp_bounds), ($confirms) confirm reads; checks: ($checks)"
    $r
  })
  {runs: $runs} | to json -i 1 | save -f $out
  print -e $"wrote ($out)"
}
