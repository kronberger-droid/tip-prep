# Index a directory of tip-prep logs into a small cache, then rank the runs.
#
# The logs on the data drive run to gigabytes each, since every pulse carries the
# full `signal_frames` TCP capture in `ExperimentData`. Parsing a whole file as
# JSON means materialising those arrays just to read one float out of the
# record next to them.
#
# The array-format files are pretty-printed, so every field the poster cares
# about sits alone on its own line at a known indentation depth. `rg` pulls
# those ~700 lines out of a 120 MB file in 0.4 s, disk-bound. One file,
# `tip_prep_20260127_145314.json`, is instead one compact record per line;
# those lines are parsed one at a time and reduced to the same fields. So:
#
#     stage 1  scan the drive once, write a compact JSON index   (minutes)
#     stage 2  rank and re-rank the index                        (instant)
#
# Usage:
#     nu scripts/index_logs.nu scan "/run/media/.../Experiments"   # -> cache
#     nu scripts/index_logs.nu report                              # re-rank
#     nu scripts/index_logs.nu report --min-pulses 10 --sharp-only

const HERE = (path self | path dirname)
const DEFAULT_CACHE = ($HERE | path join "runs_index.json")

# Anchored on exact indentation, so these are structural queries and not just
# text matches: indent 4 is a top-level record field, indent 6 inside `result`
# is the result variant name, indent 8 is a field of that variant.
const PATTERNS = [
  '^    "action": '
  '^    "result": '
  '^    "start_time": '
  '^    "duration_ms": '
  '^      "[A-Za-z_]+": \{$'
  '^      "Error": '
  '^        "stable_value": '
  '^        "shape": '
]

const BOUNDS_RE = 'bounds \((?<lo>[-0-9.e]+), (?<hi>[-0-9.e]+)\)'
# Two log generations: `Pulse retract -4.0V` (Dec 2025) and `Bias pulse
# -8.000V` (2026). The anchor leaves out the "Data Collection:" records that
# wrap and duplicate a pulse.
const PULSE_V_RE = '^(?:Pulse retract|Bias pulse) (?<volts>-?[0-9.]+)V'
const SWEEP_RE = 'bias sweep .*? from (?<from>-?[0-9.]+)V to (?<to>-?[0-9.]+)V \((?<steps>\d+) steps, (?<period>\d+)ms'

# ------------------------------------------------------------- reading logs

# The JSON value off a `    "key": <value>,` line, or its text when it is not
# a complete value.
def unquote [prefix: string] {
  let val = (
    $in
    | str substring ($prefix | str length)..
    | str trim --right
    | str trim --right --char ","
  )
  try { $val | from json } catch { $val }
}

# The value of the first line with this prefix, or null when there is none.
def unquote-first [prefix: string] {
  let line = ($in | where ($it | str starts-with $prefix) | get -o 0)
  if $line == null { null } else { $line | unquote $prefix }
}

# "array" for the pretty-printed JSON array of records, "lines" for one
# compact record per line.
def log-format [path: path] {
  if (^head -c 1 $path | complete | get stdout) == "{" { "lines" } else { "array" }
}

# A run killed mid-write never closed its top-level array, or never finished
# its last line.
def is-truncated [path: path, format: string] {
  let tail = (^tail -c 64 $path | complete | get stdout | str trim --right)
  let closer = if $format == "lines" { "}" } else { "]" }
  not ($tail | str ends-with $closer)
}

# The fields this index keeps of one record, null where the record has none.
def fields [action: any, kind: any, start: any, dur: any, error: any, df: any, shape: any] {
  {action: $action, kind: $kind, start: $start, dur: $dur, error: $error, df: $df, shape: $shape}
}

# The records of an array-format log, via ripgrep. `"action"` delimits them:
# it is the first key of every object, so a new action line means the
# previous record is complete.
def array-records [path: path] {
  let rg = (^rg -N ...($PATTERNS | each {|p| ["-e" $p] } | flatten) -- $path | complete)
  if $rg.exit_code > 1 {
    error make {msg: $"rg failed on ($path): ($rg.stderr)"}
  }
  $rg.stdout
  | lines
  | split list -r '^    "action": ' --split before
  | where ($it | is-not-empty)
  | each {|group|
      let rest = ($group | skip 1)
      let result = ($rest | where ($it | str starts-with '    "result": ') | get -o 0)
      let error = ($rest | unquote-first '      "Error": ')
      let variant = (
        $rest
        | where {|l| ($l | str starts-with '      "') and ($l | str trim --right | str ends-with "{") }
        | get -o 0
      )
      let kind = if $result == null {
        null
      } else if ($result | str substring 14.. | str trim | str starts-with "{") == false {
        $result | unquote '    "result": '
      } else if $error != null {
        "Error"
      } else if $variant != null {
        $variant | str trim | split row '"' | get 1     # variant name lands on its own line
      } else {
        "?"
      }
      fields ($group | first | unquote '    "action": ') $kind ($rest | unquote-first '    "start_time": ') ($rest | unquote-first '    "duration_ms": ') $error ($rest | unquote-first '        "stable_value": ') ($rest | unquote-first '        "shape": ')
    }
}

# The records of a one-per-line log. A line that does not parse, the cut-off
# last line of a run killed mid-write, is skipped.
def line-records [path: path] {
  open --raw $path
  | lines
  | each {|line|
      let r = (try { $line | from json } catch { null })
      if $r != null {
        let result = $r.result?
        let variants = if ($result | describe) =~ '^record' { $result } else { {} }
        let kind = if $result == null {
          null
        } else if ($result | describe) == "string" {
          $result
        } else {
          $variants | columns | get -o 0
        }
        fields $r.action? $kind $r.start_time? $r.duration_ms? $variants.Error? $variants.StableSignal?.stable_value? $variants.TipState?.shape?
      }
    }
}

def summarise [path: path] {
  let format = (log-format $path)
  let recs = if $format == "lines" { line-records $path } else { array-records $path }
  let actions = ($recs | get action | compact)
  let df = ($recs | where df != null | get df)
  let pulse_v = ($actions | parse -r $PULSE_V_RE | get volts | into float)
  let bounds = ($actions | where ($it | str contains "Check tip state") | parse -r $BOUNDS_RE | get -o 0)
  let sweep = ($actions | where ($it | str contains "Check tip stability") | parse -r $SWEEP_RE | get -o 0)
  let timed = ($recs | where start != null)
  let secs = if ($timed | is-empty) {
    null
  } else {
    let first = ($timed | first)
    let last = ($timed | last)
    let span = ((($last.start | into datetime) - ($first.start | into datetime)) / 1sec)
    $span + (($last.dur | default 0) / 1000.0)
  }

  {
    file: ($path | path basename)
    size_mb: ((ls $path | get 0.size | into int) / 1000000.0 | math round -p 1)
    truncated: (is-truncated $path $format)
    entries: ($recs | length)
    seconds: (if $secs == null or $secs == 0 { null } else { $secs | math round -p 1 })
    pulses: ($pulse_v | length)
    pulse_v: ($pulse_v | uniq | sort)
    reads: ($df | length)
    df: ($df | each { math round -p 3 })
    shapes: ($recs | where shape != null | get shape)
    sharp_bounds: (if $bounds == null { null } else { [($bounds.lo | into float) ($bounds.hi | into float)] })
    sweep: (if $sweep == null { null } else {
      {
        from: ($sweep.from | into float)
        to: ($sweep.to | into float)
        steps: ($sweep.steps | into int)
        period_ms: ($sweep.period | into int)
      }
    })
    stability_results: (
      $recs
      | where ($it.action | default "" | str contains "Check tip stability")
      | each {|r| $r.kind | default "Success" }
    )
    errors: (
      $recs
      | where kind == "Error"
      | first 5
      | each {|r| [($r.action | str substring -g 0..59) ($r.error | default "" | into string | str substring -g 0..119)] }
    )
  }
}

# ---------------------------------------------------------------- reporting

# Δf climbing toward the sharp band (bounds are negative, target ~0).
def gain [s: record] {
  ($s.df | first | math abs) - ($s.df | last | math abs)
}

def signed [v: number] {
  let text = ($v | math round -p 1 | into string -d 1)
  if $v >= 0 { $"+($text)" } else { $text }
}

# Classify a run the way the Proof of Concept panel would read it.
def verdict [s: record] {
  if ($s.df | is-empty) { return "no reads" }
  if "Sharp" not-in $s.shapes { return "never sharp" }
  if ($s.df | length) < 2 { return "sharp, single read" }
  if $s.pulses == 0 { return "already sharp" }
  # Deliberately not "converged": the loop is a random search that either
  # lands in the band or does not. Calling it convergence implies a trend the
  # traces do not show. See the house-style note in CLAUDE.md.
  let gain = (gain $s)
  if $gain > 0 { $"reached band (signed $gain) Hz" } else { $"worse (signed $gain) Hz" }
}

# Rank for poster use: sharp, long, big honest improvement, intact.
def score [s: record] {
  if ($s.df | is-empty) or ("Sharp" not-in $s.shapes) { return (-1) }
  let base = ($s.pulses * 2 + ([(gain $s) 0] | math max))
  let intact = if $s.truncated { -5 } else { 0 }
  # A passed stability check is what the poster lacks.
  let stable = if ($s.stability_results | any {|k| $k != "Error" }) { 25 } else { 0 }
  $base + $intact + $stable
}

# The runs as a table, best poster candidate first.
def rank [index: list, --min-pulses: int = 0, --sharp-only] {
  $index
  | where pulses >= $min_pulses
  | where (not $sharp_only) or ("Sharp" in $it.shapes)
  | sort-by -r {|s| score $s }
  | each {|s|
      let checks = $s.stability_results
      {
        file: ($s.file | str replace "tip_prep_" "")
        mb: $s.size_mb
        entries: $s.entries
        s: ($s.seconds | default 0 | math round)
        pulses: $s.pulses
        reads: $s.reads
        df: (if ($s.df | is-empty) { "" } else {
          $"($s.df | first | into string -d 2) → ($s.df | last | into string -d 2)"
        })
        stab: (if ($checks | is-empty) { "" } else {
          $"($checks | where $it != 'Error' | length)/($checks | length)"
        })
        verdict: $"(if $s.truncated { 'TRUNC ' } else { '' })(verdict $s)"
      }
    }
}

# Scan every tip_prep_*.json under DIR into the cache, then rank them.
def "main scan" [dir: path, --cache: path = $DEFAULT_CACHE, --min-pulses: int = 0, --sharp-only] {
  let paths = (ls ($dir | path join "tip_prep_*.json" | into glob) | get name | sort)
  let index = ($paths | enumerate | each {|p|
    print -e $"[($p.index + 1)/($paths | length)] ($p.item | path basename)"
    try { summarise $p.item } catch {|e| print -e $"    failed: ($e.msg)" }   # keep going
  })
  $index | to json -i 1 | save -f $cache
  print -e $"wrote ($cache) \(($index | length) runs\)"
  rank $index --min-pulses $min_pulses --sharp-only=$sharp_only
}

# Rank the runs in the cache; works with the drive unplugged.
def "main report" [--cache: path = $DEFAULT_CACHE, --min-pulses: int = 0, --sharp-only] {
  rank (open $cache) --min-pulses $min_pulses --sharp-only=$sharp_only
}

def main [] {
  print -e "usage: nu scripts/index_logs.nu scan DIR | report [--min-pulses N] [--sharp-only]"
  exit 2
}
