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
# the file's records in order.
#
# `--lines` is a regex; when given, only the lines it matches, plus every
# `run_finished` line, are decoded. Decoding is where the time goes: the 106
# logs take 5 s to decode whole and under a second after the filter, and
# everything a script needs sits on a line that names it. The files are
# decoded in parallel, so a consumer sees all rows at once; `par-each` is
# left to finish in any order and the rows sorted after, since
# `--keep-order` costs more than the sort.
export def counted-logs [root: path, --lines: string] {
  let keep = if $lines == null { null } else { $"($lines)|run_finished" }
  ls ($root | path join "tip_prep_*.jsonl" | into glob)
  | get name
  | where {|p|
      let day = ($p | path basename | str substring 9..16)
      $day >= $FIRST and $day <= $LAST
    }
  | par-each {|p|
      let text = (open --raw $p)
      let records = if $keep == null {
        $text | from json --objects
      } else {
        $text | lines | where $it =~ $keep | each { from json }
      }
      let outcome = ($records | where type == run_finished | get -o 0.outcome)
      if $outcome in $COUNTED {
        {name: ($p | path basename), outcome: $outcome, records: $records}
      }
    }
  | sort-by name
}

# Where a script's result goes: data/<stem>.json, next to scripts/.
export def data-path [stem: string] {
  $HERE | path join ".." "data" $"($stem).json" | path expand
}

# Write a result the way the figures read it: pretty JSON, trailing newline.
export def save-data [stem: string] {
  $"($in | to json --indent 2)\n" | save --force (data-path $stem)
}
