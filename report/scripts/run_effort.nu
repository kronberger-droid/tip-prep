# Pulses and minutes of each completed run, for fig_effort.
#
# Reads the run logs the report counts (see logs.nu) and writes
# data/run_effort.json with one entry per completed run. Pulses are the run's
# `tip_prep/cycle` events; minutes are the `run_finished` duration, which the
# logs give in milliseconds.
#
# Usage:
#     nu scripts/run_effort.nu "/run/media/kronberger/DATA/Tip Prep/Experiments"

use logs.nu [FIRST LAST counted-logs save-data]

def main [root: path] {
  let logs = (counted-logs $root --lines 'tip_prep/cycle' | each {|log|
    {
      log: $log.name
      outcome: $log.outcome
      pulses: ($log.records | where type == custom | where kind == "tip_prep/cycle" | length)
      minutes: ($log.records | where type == run_finished | first | get duration | $in / 60000 | math round -p 3)
    }
  })
  let runs = ($logs | where outcome == completed | select log pulses minutes)
  let pulsed = ($runs | where pulses > 0)
  let result = {
    source: $"($logs | length) counted tip_prep logs, ($FIRST) to ($LAST)"
    completed: ($runs | length)
    without_pulse: (($runs | length) - ($pulsed | length))
    median_pulses: ($pulsed.pulses | math median)
    median_minutes: ($pulsed.minutes | math median | math round -p 2)
    runs: $runs
  }
  $result | save-data run_effort
  $result | reject runs
}
