# Histogram of the accepted frequency-shift readings, for fig_readings.
#
# Reads the run logs the report counts (see logs.nu) and writes
# data/readings.json: counts per 2 Hz bin from -80 to +80 Hz, split by whether
# the reading passed the noise and drift gates or failed them on every retry,
# plus the readings outside that span.
#
# A reading is a `data_collected` record labelled `stable_read`; `stable`
# false means it failed the gates on every retry and was used anyway.
#
# Usage:
#     nu scripts/readings.nu "/run/media/kronberger/DATA/Tip Prep/Experiments"

use logs.nu [FIRST LAST counted-logs save-data]

const LO = -80
const HI = 80
const WIDTH = 2
const RAIL = 76.29

def main [root: path] {
  let n = (($HI - $LO) // $WIDTH)
  let reads = (
    counted-logs $root --lines stable_read
    | each {|log| $log.records | where type == data_collected | where label == stable_read | get value }
    | flatten
    | each {|r|
        {
          value: $r.value
          bin: ((($r.value - $LO) / $WIDTH) | math floor)
          key: (if $r.stable { "passed" } else { "failed" })
        }
      }
  )
  let inside = ($reads | where bin >= 0 and bin < $n)
  let outside = ($reads | where bin < 0 or bin >= $n)
  # One pass over the readings, then 160 lookups; a `where` per bin costs 1 s.
  let counts = ($inside | group-by {|r| $"($r.key)/($r.bin)" })
  let passed = (0..<$n | each {|i| $counts | get -o $"passed/($i)" | default [] | length })
  let failed = (0..<$n | each {|i| $counts | get -o $"failed/($i)" | default [] | length })
  let result = {
    source: $"stable_read records of the counted tip_prep logs, ($FIRST) to ($LAST)"
    readings: ($reads | length)
    at_rail: ($reads | where {|r| ((($r.value | math abs) - $RAIL) | math abs) < 0.015 } | length)
    bin_width_hz: $WIDTH
    bin_starts_hz: (0..<$n | each {|i| $LO + $i * $WIDTH })
    passed: $passed
    failed: $failed
    outside: {
      passed: ($outside | where key == passed | length)
      failed: ($outside | where key == failed | length)
    }
  }
  $result | save-data readings
  {
    readings: $result.readings
    at_rail: $result.at_rail
    outside: $result.outside
    passed: ($passed | math sum)
    failed: ($failed | math sum)
    max_bin: ($passed | zip $failed | each { math sum } | math max)
  }
}
