# Tip-Prep Report

Project report on automated SPM tip conditioning. `README.md` covers the build,
the file layout and the template parameters. This file covers how the text gets
written.

## How we write

Martin drafts a section by feel, in one pass, building it up without stopping
to get it right. Then we go over it together: refine the prose, cut what does
not earn its place, add figures and cross-references.

Two rules fall out of that:

- A section that is still a placeholder stays a placeholder. Sketch structure,
  answer questions, pull facts out of the code — but the first draft of the
  prose is Martin's.
- A section that has a draft is open for editing. Say which pass you are
  running, a line pass (sentences) or a structure pass (what sits where), and
  run one at a time.

The `scientific-writing` skill carries the editing conventions.

## Commits

No `Co-Authored-By` trailers here, overriding the global default. The
declaration page states the LLM use for the whole work, which is where a reader
looks for it; a trailer on every commit adds nothing and clutters the log. The
older template commits still carry theirs and keep them.

## Claims

Every number, citation and hedge traces to a source: the code, the poster, the
abstract, or measured data. Where a source is missing, mark the gap and ask.
Inventing a plausible DOI, title or figure is the one unrecoverable mistake
here, because it reads exactly like a checked one.

## Sources of truth

| Source | Holds |
|---|---|
| `~/Projects/rust/rusty-tip` | the framework and the routine, as they are now |
| `~/Projects/rust/nanonis-rs` | the protocol client, `src/protocol.rs` for the wire format |
| `../tip-prep-poster/main.typ` | PI-reviewed prose, and the figures worth reusing |
| `~/Documents/work/university/seminars/2026_nc_afm/abstract/` | the submitted NC-AFM 2026 abstract |
| `../tip-prep-poster/refs.bib` | the maintained bibliography |

`src/B_bibliography/references.bib` is a copy of the poster's; keep the two in
step. Where the poster and the abstract disagree, the poster is later and
reviewed.

The report describes the current implementation. Earlier proof-of-concepts
appear only as the lessons in @sec:poc-lessons, never as the thing being
described.

## Structure

- Body target is about ten pages.
- A chapter opens with lead-in prose under its title. A subsection is for a
  topic a reader arrives at directly, from the contents or a cross-reference.
  Anything that is one paragraph of a larger argument stays a paragraph.
- Section titles are formal noun phrases: `Connection management and tip
  safety`, not `What type safety bought`.
- Cross-reference by label. A dangling `@sec:` fails the build, which is how a
  restructure announces what it broke.
