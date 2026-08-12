# Tip Preparation

Report written in [Typst](https://typst.app/), using the report template from
[labor-III](https://github.com/kronberger-droid/labor-III) with the course-specific
wording lifted into template parameters.

## Building

```sh
typst compile main.typ main.pdf
```

Or watch mode for live preview:

```sh
typst watch main.typ main.pdf
```

Requires Typst 0.15 or later and the `New Computer Modern` font. Packages
(`lilaq`, `unify`) are fetched on first compile.

## Structure

`main.typ` is a driver, the way `main.tex` is in the thesis: it sets the
template options and `#include`s one file per chapter, so chapters are written
separately and never collide.

```
main.typ                            template options + #include list
report.typ                          title page, page style, LaTeX metrics
lib.typ                             mean, standard deviation, linear fit
src/00_intro/                       declaration, abstract, introduction
src/01_scope-and-objectives/        one directory per chapter, each with a
src/02_foundations/                 default.typ; split a long chapter across
src/03_instrument-interface/        more files and #include them from its
src/04_framework/                   own default.typ
src/05_routine/
src/06_validation/
src/07_discussion/
src/08_outlook/
src/09_conclusion/
src/A_appendix/
src/B_bibliography/references.bib
assets/                             the TU Wien logo
data/                               raw measurement data
```

Figures belong next to the chapter that uses them (`src/02_foundations/fig_*`),
since `#include` resolves paths relative to the including file. `assets/` is
only for what the template itself needs.

## Formalities

`report()` assembles the same sequence as the thesis, in this order:

1. title page (followed by a blank verso only when `two-sided`)
2. `front-matter` — declaration and abstract. Counted but shown without header
   or page number, as `\pagenumbering{roman}` with `\pagestyle{empty}` leaves
   it.
3. table of contents, unless `outline-contents: false`
4. the body, restarting at arabic page 1 with the running header
5. `appendix` — sections renumbered A, B, C, as `\appendix` does
6. `back-matter` — lists of figures and tables, and the bibliography

Helpers exported alongside `report`:

| Helper | LaTeX equivalent |
|---|---|
| `unnumbered(title, outlined: true)` | `\section*` plus `\addcontentsline`; `outlined: false` to keep it out of the contents |
| `blank-page()` | `\blankpage` |
| `declaration(author:, place:, date:)[..]` | the declaration page layout, with the wording left to you |
| `list-of-figures()`, `list-of-tables()` | `\listoffigures`, `\listoftables` |

## Page style

Ported from the LaTeX preamble of
[thesis-bachelor](https://github.com/kronberger-droid/thesis-bachelor), so the
output matches that document:

- **Geometry** (`geometry`): a4, two-sided, inner 3cm plus a 1cm binding offset,
  outer 2.5cm, 2.5cm top and bottom. A blank verso follows the title page, which
  keeps the printed page numbers in step with the alternating margins.
- **Header and footer** (`fancyhdr`): the section on the left of even pages, the
  subsection on the right of odd ones, under a 0.4pt rule, with the page number
  in the outer bottom corner. A section clears the subsection mark, so a page
  that opens a section carries an empty header.
- **Font sizes** (`size11.clo`): the 11pt article class, so 11pt body on a
  13.6pt baseline, 12pt bold sections, 11pt bold subsections, 10pt captions.
  Note these are the round values; the 10.95 / 11.955 / 14.4 series belongs to
  the *10pt* class and makes every heading a little too large.
- **Headings** (`titlesec`): number and title separated by 0.5em, with the
  article-class `\titlespacing` around them.
- **Paragraphs**: justified, no space between them, 17pt first-line indent
  except directly after a heading.
- **Contents** (`\l@section`, `\@dottedtocline`): section entries bold with no
  dot leaders, subsections indented 1.5em and sub-subsections 3.8em, both with
  leaders on an 8.5pt pitch. Numbers sit in a fixed column so titles line up,
  and page numbers are right-aligned in a `\@pnumwidth` box. Unnumbered entries
  reserve no column and sit flush left.
- **Numbering depth** (`\secnumdepth`, `\tocdepth`): three levels, so
  sub-subsections are numbered and reach the contents.
- **Equations** (`\numberwithin`): numbered per section, `(2.1)`, `(2.2)`.
- **Captions** (`captionsetup`): 10pt, bold label, separated by a period.

Set `two-sided: false` for symmetric margins, no blank verso, and a fixed
header. This report sets it, since it is read on screen rather than printed, so
the geometry above describes the template's default and not this document.
`margin` overrides the geometry outright.

## Template parameters

The title page follows the LaTeX front page from the same repository
(`src/00_intro/title.tex`).

| Parameter | Purpose |
|---|---|
| `document-type`, `title` | The two lines between the rules. `document-type` is the large bold one, `[Report]` by default. |
| `institution`, `faculty`, `institute` | Smallcaps lines below the rules. `faculty` is `none` by default. |
| `advisors`, `advisors-label` | Names in bold under "under guidance of". |
| `authors`, `authors-label`, `matriculation` | Names in bold under "submitted by", with the matriculation number beneath. |
| `supervisor` | Used for the signature line only; the printed list above is `advisors`. |
| `signatures`, `signature-width` | Signature lines at the foot. `auto` derives Author and Supervisor; `none` omits the block; otherwise an array of `(label: .., name: ..)`. |
| `date`, `date-format` | A `datetime` is formatted with `date-format`; any other value prints as given, so `date: [Summer term 2026]` works. |
| `logo`, `logo-width`, `rule-stroke` | Title page furniture. |
| `groupnumber`, `two-sided`, `margin`, `language` | `two-sided` drives the alternating margins and header marks; `margin` overrides the geometry. |

Every text field accepts either a string or content, so `title: [ Conditioning
of _SPM_ Tips ]` works, as does a content entry in `authors` or `advisors`.
Passing `none` omits a block entirely rather than leaving a gap.

## License

[MIT](LICENSE)
