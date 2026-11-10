# Median duration of each phase of one tip-preparation cycle, for fig_cycle.
#
# Reads the run logs the report counts (see logs.nu) and writes
# data/cycle_durations.json.
#
# Only calibrated approaches that re-land through the Z loop (`z_controller_set`
# between the two landing gates) are used, since that is the code path the
# figure draws; earlier revisions re-landed with a second auto-approach.
#
# Usage:
#     nu scripts/cycle_durations.nu "/run/media/kronberger/DATA/Tip Prep/Experiments"

use logs.nu [FIRST LAST counted-logs save-data]

# The steps of each top-level reposition, one list per cycle: everything
# completed between the reposition starting and completing, as
# {action, depth, duration}.
def cycle-steps [] {
  mut cycles = []
  mut current = []
  mut open = false
  for r in $in {
    if $r.type == action_started and $r.action == reposition and $r.depth == 0 {
      $current = []
      $open = true
    } else if $open and $r.type == action_completed {
      if $r.action == reposition and $r.depth == 0 {
        $cycles = ($cycles | append [$current])
        $open = false
      } else {
        $current = ($current | append {action: $r.action, depth: $r.depth, duration: $r.duration})
      }
    }
  }
  $cycles
}

# Duration of the last step with this action, or null when there is none.
def last-duration [action: string] {
  let hits = ($in | where action == $action)
  if ($hits | is-empty) { null } else { $hits | last | get duration }
}

# Durations of one cycle's phases, or null for a cycle that did not re-land
# through the Z loop.
def phases [] {
  let steps = $in
  let top = ($steps | where depth == 1)
  let inner = ($steps | where depth == 2)
  let names = ($inner | get action)
  let gates = ($inner | where action == settle_on_setpoint | get duration)
  if "z_controller_set" not-in $names or ($gates | length) != 2 {
    return null
  }
  let z_set = ($names | enumerate | where item == z_controller_set | first | get index)
  {
    withdraw: ($top | last-duration withdraw)
    coarse_step: ($top | last-duration move_motor_3d)
    approach: (($inner | where action == auto_approach | first | get duration) + ($gates | first))
    home: (
      $inner | take $z_set
      | where action in [z_home wait center_freq_shift safe_tip_set]
      | get duration | math sum
    )
    reland: (($inner | get $z_set | get duration) + ($gates | get 1))
  }
}

def median-ms [] {
  $in | compact | math median | math round -p 1
}

def main [root: path] {
  let runs = (counted-logs $root | each {|log|
    let done = ($log.records | where type == action_completed)
    {
      pulses: ($done | where action == bias_pulse | get duration)
      reads: ($done | where action == read_stable_signal | get duration)
      cycles: ($log.records | cycle-steps | each { phases })
    }
  })
  let cycles = ($runs.cycles | flatten)
  let result = {
    source: $"($runs | length) counted tip_prep logs, ($FIRST) to ($LAST)"
    cycles: ($cycles | length)
    median_ms: {
      pulse: ($runs.pulses | flatten | median-ms)
      withdraw: ($cycles.withdraw | median-ms)
      coarse_step: ($cycles.coarse_step | median-ms)
      approach: ($cycles.approach | median-ms)
      home: ($cycles.home | median-ms)
      reland: ($cycles.reland | median-ms)
      read: ($runs.reads | flatten | median-ms)
    }
  }
  $result | save-data cycle_durations
  $result
}
