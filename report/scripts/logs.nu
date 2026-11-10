# Shared by the report's data scripts: which run logs the report counts.
#
# The report counts tip_prep_*.jsonl from 2026-09-15 to 2026-10-06 whose run
# finished `completed` or `stopped_by_user`, as in src/06_validation.
# Durations in the logs are milliseconds.

export const FIRST = "20260915"
export const LAST = "20261006"
export const COUNTED = ["completed" "stopped_by_user"]

const HERE = (path self | path dirname)

# One row per counted log, in name order: `name`, `outcome` and `records`,
# the file's records in order. The rows stream, so a consumer that keeps only
# what it needs never holds more than one log's records at a time.
export def counted-logs [root: path] {
  ls ($root | path join "tip_prep_*.jsonl" | into glob)
  | get name
  | sort
  | where {|p|
      let day = ($p | path basename | str substring 9..16)
      $day >= $FIRST and $day <= $LAST
    }
  | each {|p|
      let records = (open --raw $p | from json --objects)
      let outcome = ($records | where type == run_finished | get -o 0.outcome)
      if $outcome in $COUNTED {
        {name: ($p | path basename), outcome: $outcome, records: $records}
      }
    }
}

# Where a script's result goes: data/<stem>.json, next to scripts/.
export def data-path [stem: string] {
  $HERE | path join ".." "data" $"($stem).json" | path expand
}

# Write a result the way the figures read it: pretty JSON, trailing newline.
export def save-data [stem: string] {
  $"($in | to json --indent 2)\n" | save --force (data-path $stem)
}
