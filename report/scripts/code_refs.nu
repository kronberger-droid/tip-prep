# Where the code items the report names live in rusty-tip, for the code
# reference table (tab:code), the listings after it and the linked mentions
# in the text.
#
# Resolves each item and each listing below at one revision of rusty-tip and writes
# data/code_refs.json. The lines are read from the revision, never from the
# working tree, so the table and the links agree with the permalink they give.
# A pattern that does not match exactly once is an error: after a rename or a
# move in rusty-tip, fix the entry here and run this again.
#
# Usage:
#     nu scripts/code_refs.nu ~/Projects/rust/rusty-tip main

use logs.nu [save-data]

const REPO_URL = "https://github.com/kronberger-droid/rusty-tip"

# group: the table's section. term: the report's word for the item.
# item: the name as the table prints it, and the key `code()` in lib.typ takes.
# pattern: a regex for the declaring line, anchored so it matches once.
const ITEMS = [
  [group, term, item, file, pattern];

  ["Hardware abstraction", "controller interface", "SpmController", "src/spm_controller.rs", '^pub trait SpmController\b']
  ["Hardware abstraction", "capability", "Capability", "src/spm_controller.rs", '^pub enum Capability\b']
  ["Hardware abstraction", "error on a missing capability", "SpmError::Unsupported", "src/spm_error.rs", '^\s+Unsupported\(']
  ["Hardware abstraction", "Nanonis backend", "NanonisController", "src/nanonis_controller.rs", '^pub struct NanonisController\b']
  ["Hardware abstraction", "mock backend", "MockController", "src/mock_controller.rs", '^pub struct MockController\b']
  ["Hardware abstraction", "injected fault", "FaultKind", "src/mock_controller.rs", '^pub enum FaultKind\b']
  ["Hardware abstraction", "recorded calls", "MockObservations", "src/mock_controller.rs", '^pub struct MockObservations\b']

  ["Routine harness", "routine", "Routine", "src/routine/mod.rs", '^pub trait Routine\b']
  ["Routine harness", "a routine's body", "Routine::run", "src/routine/mod.rs", '^    fn run\(']
  ["Routine harness", "what a routine declares it needs", "RunSetup", "src/routine/mod.rs", '^pub struct RunSetup\b']
  ["Routine harness", "exit policy", "ExitPolicy", "src/routine/mod.rs", '^pub enum ExitPolicy\b']
  ["Routine harness", "outcome", "Outcome", "src/routine/mod.rs", '^pub enum Outcome\b']
  ["Routine harness", "harness", "run_routine", "src/routine/mod.rs", '^pub fn run_routine\(']
  ["Routine harness", "runtime", "Rt", "src/routine/rt.rs", '^pub struct Rt\b']
  ["Routine harness", "subsystem handle, bias", "Rt::bias", "src/routine/rt.rs", '^    pub fn bias\(']
  ["Routine harness", "subsystem handle, Z-controller", "Rt::z", "src/routine/rt.rs", '^    pub fn z\(']
  ["Routine harness", "subsystem handle, scan", "Rt::scan", "src/routine/rt.rs", '^    pub fn scan\(']
  ["Routine harness", "cleanup", "Rt::guarded", "src/routine/rt.rs", '^    pub fn guarded<']
  ["Routine harness", "cycle driver", "Cycles", "src/routine/rt.rs", '^pub struct Cycles\b']
  ["Routine harness", "cancellation", "ShutdownFlag", "src/shutdown.rs", '^pub struct ShutdownFlag\b']
  ["Routine harness", "session", "Session", "src/session.rs", '^pub struct Session\b']
  ["Routine harness", "job", "Job", "src/session.rs", '^pub trait Job\b']
  ["Routine harness", "operating point", "OperatingPoint", "src/operating_point.rs", '^pub struct OperatingPoint\b']

  ["Event system", "event bus", "EventBus", "src/event/mod.rs", '^pub struct EventBus\b']
  ["Event system", "event", "Event", "src/event/mod.rs", '^pub enum Event\b']
  ["Event system", "observer", "Observer", "src/event/observer.rs", '^pub trait Observer\b']
  ["Event system", "observer writing the log", "FileLogger", "src/event/observer.rs", '^pub struct FileLogger\b']
  ["Event system", "observer printing to the console", "ConsoleLogger", "src/event/observer.rs", '^pub struct ConsoleLogger\b']
  ["Event system", "observer feeding the workbench", "ChannelForwarder", "src/event/observer.rs", '^pub struct ChannelForwarder\b']
  ["Event system", "log header", "RunHeader", "src/experiment_log/mod.rs", '^pub struct RunHeader\b']
  ["Event system", "schema of an event type", "EventKindSchema", "src/experiment_log/mod.rs", '^pub struct EventKindSchema\b']

  ["Tip preparation", "the routine", "TipPrep", "src/tip_prep/runner.rs", '^pub struct TipPrep\b']
  ["Tip preparation", "configuration", "TipPrepConfig", "src/config.rs", '^pub struct TipPrepConfig\b']
  ["Tip preparation", "voltage strategies", "PulseState", "src/tip_prep/pulse_state.rs", '^pub struct PulseState\b']
  ["Tip preparation", "cycle event", "CycleEvent", "src/tip_prep/events.rs", '^pub struct CycleEvent\b']
  ["Tip preparation", "phase change", "PhaseEvent", "src/tip_prep/events.rs", '^pub enum PhaseEvent\b']
  ["Tip preparation", "maximum-voltage pulse", "MaxPulseEvent", "src/tip_prep/events.rs", '^pub struct MaxPulseEvent\b']
  ["Tip preparation", "configuration change", "ConfigReloadedEvent", "src/tip_prep/events.rs", '^pub struct ConfigReloadedEvent\b']

  ["Analyzers", "analyzer", "Analyzer", "src/analyzer/mod.rs", '^pub trait Analyzer\b']
]

# The code the appendix prints, in this order. A listing shows how something
# the text describes is modelled, not the library's API: keep it to few.
#
# A listing is one or more fragments. A fragment runs from the line matching
# `from` (which must match once in the file) to the line reached by matching
# the `to` patterns one after another from there. `cuts` are ranges inside
# the fragment (optional), both ends found by such a chain, replaced by a `// ...` line;
# a fragment with cuts is marked as abridged. `caption` is Typst markup.
const LISTINGS = [
  {
    label: "routine"
    caption: "The interface a routine implements"
    fragments: [
      {file: "src/routine/mod.rs", from: '^/// An automation routine, runnable', to: ['^}$']}
    ]
  }
  {
    label: "operation"
    caption: "The path of one operation, here a bias pulse. Obtaining the handle checks the capability, the handle's method names an action, and the executor the handle passes it to reports its start and its end to the event bus"
    fragments: [
      {file: "src/routine/rt.rs", from: '^    /// Bias voltage control\.', to: ['^    }$']}
      {file: "src/routine/rt.rs", from: '^pub\(crate\) fn require\(', to: ['^}$']}
      {file: "src/routine/subsystems.rs", from: '^    /// Fire a bias pulse to an absolute signed voltage', to: ['^    }$']}
      {file: "src/action/mod.rs", from: '^/// Run `action` in `ctx`: check its capabilities', to: ['^}$']}
    ]
  }
  {
    label: "backends"
    caption: "The same operation behind the controller interface. The interface asks a backend for its capabilities, gives an optional operation a default that reports it unsupported and leaves a required one without a body; the Nanonis backend translates the bias pulse into a call of the protocol client, and the mock backend records it"
    fragments: [
      {
        file: "src/spm_controller.rs"
        from: '^pub trait SpmController: Send \{$'
        to: ['^    fn bias_pulse\($', '^    \) -> Result<\(\)>;$']
        cuts: [
          {from: ['^    // -- Lifecycle --$'], to: ['^    fn reconnect\(', '^    }$']}
          {from: ['^    /// Load a layout file into the controller'], to: ['^    fn signal_names\(']}
        ]
      }
      {file: "src/nanonis_controller.rs", from: '^    fn bias_pulse\($', to: ['^    }$']}
      {file: "src/mock_controller.rs", from: '^    fn bias_pulse\($', to: ['^    }$']}
    ]
  }
  {
    label: "tip-prep-setup"
    caption: "What tip preparation declares to the harness: the settings it needs in place for the run and how the tip is left afterwards"
    fragments: [
      {file: "src/tip_prep/runner.rs", from: '^impl Routine for TipPrep', to: ['^    fn exit_policy', '^    }$']}
    ]
  }
  {
    label: "tip-prep-loop"
    caption: "The cycle of tip preparation, the main loop of its `run` method"
    fragments: [
      {
        file: "src/tip_prep/runner.rs"
        from: '^        // Main loop: pulse -> settle -> reposition'
        to: ['^        Ok\(cycles\.outcome\(\)\)$']
        cuts: [
          {from: ['^            if cycle % timing\.status_interval == 0 \{$'], to: ['^            }$']}
          {from: ['^            let pulse_voltage = ', '^            log::info!\($'], to: ['^            \);$']}
          {from: ['^            if is_sharp \{$', '^                log::info!\($'], to: ['^                \);$']}
        ]
      }
    ]
  }
  {
    label: "linear"
    caption: "The linear voltage strategy"
    fragments: [
      {file: "src/tip_prep/pulse_state.rs", from: '^/// The Linear strategy.s pulse magnitude', to: ['^}$']}
    ]
  }
]

# Index of the line reached by matching `pats` in turn, starting at `start`.
def seek [src: list<string>, start: int, pats: list<string>, what: string] {
  mut i = $start
  for p in $pats {
    let rest = ($src | enumerate | skip $i | where item =~ $p)
    if ($rest | is-empty) {
      error make {msg: $"($what): nothing matches ($p) from line ($i + 1)"}
    }
    $i = $rest.0.index
  }
  $i
}

# Index of the only line matching `pat`.
def only [src: list<string>, pat: string, what: string] {
  let hits = ($src | enumerate | where item =~ $pat)
  if ($hits | length) != 1 {
    error make {msg: $"($what): ($hits | length) matches for ($pat)"}
  }
  $hits.0.index
}

def fragment [src: list<string>, spec: record, what: string] {
  let first = (only $src $spec.from $what)
  let last = (seek $src $first $spec.to $what)
  let cuts = ($spec.cuts? | default [] | each {|c|
    let a = (seek $src $first $c.from $what)
    {a: $a, b: (seek $src $a $c.to $what)}
  })
  let kept = ($src | enumerate | slice $first..$last | each {|l|
    let cut = ($cuts | where a <= $l.index and b >= $l.index)
    if ($cut | is-empty) {
      $l.item
    } else if $cut.0.a == $l.index {
      ($l.item | str replace -r '\S.*$' '') + "// ..."
    }
  })
  # Shift the fragment to the left margin; a method's body sits indented.
  let indent = ($kept | where $it !~ '^\s*$' | each {|l| $l | parse -r '^(?<ws> *)' | get 0.ws | str length } | math min)
  let kept = ($kept | each {|l| if ($l | str length) >= $indent { $l | str substring $indent.. } else { $l } })
  {
    file: $spec.file
    first_line: ($first + 1)
    last_line: ($last + 1)
    abridged: ($cuts | is-not-empty)
    source: ($kept | str join "\n")
  }
}

def git-out [repo: path, ...args: string] {
  let r = (^git -C $repo ...$args | complete)
  if $r.exit_code != 0 {
    error make {msg: $"git ($args | str join ' '): ($r.stderr | str trim)"}
  }
  $r.stdout
}

def main [
  repo: path # a checkout of rusty-tip
  rev: string # the branch, tag or commit to pin, e.g. main or v0.6.0
] {
  let sha = (git-out $repo rev-parse $"($rev)^{commit}" | str trim)

  # Each file is read from the revision once, for the items and the listings.
  let files = ($ITEMS.file ++ ($LISTINGS.fragments | flatten | get file) | uniq)
  let sources = ($files | reduce --fold {} {|file, acc|
    $acc | insert $file (git-out $repo show $"($sha):($file)" | lines)
  })

  let items = ($ITEMS | each {|entry|
    let line = (only ($sources | get $entry.file) $entry.pattern $"($entry.item) in ($entry.file) at ($rev)")
    $entry | reject pattern | insert line ($line + 1)
  })

  let dupes = ($items.item | uniq -d)
  if ($dupes | is-not-empty) {
    error make {msg: $"duplicate items: ($dupes | str join ', ')"}
  }

  let listings = ($LISTINGS | each {|l|
    $l | update fragments {|row|
      $row.fragments | each {|spec|
        fragment ($sources | get $spec.file) $spec $"listing ($l.label), ($spec.file)"
      }
    }
  })

  let result = {
    repo: $REPO_URL
    rev: $rev
    commit: $sha
    items: $items
    listings: $listings
  }
  $result | save-data code_refs
  print ($items | select item file line | to text)
  $listings | each {|l| $l.fragments | each {|f| $"($l.label): ($f.file):($f.first_line)-($f.last_line)(if $f.abridged { ' abridged' })" } } | flatten | to text
}
