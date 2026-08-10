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

- `main.typ` — document content
- `report.typ` — title page and document-wide `set` rules, applied via `#show`
- `lib.typ` — data analysis helpers (mean, standard deviation, linear fit)
- `refs.bib` — bibliography
- `assets/` — figures and the TU Wien logo
- `data/` — raw measurement data

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
- **Headings** (`titlesec`): 14pt bold sections and 11pt bold subsections, number
  and title separated by 0.5em.
- **Paragraphs**: justified, no space between them, 17pt first-line indent
  except directly after a heading.
- **Equations** (`\numberwithin`): numbered per section, `(2.1)`, `(2.2)`.
- **Captions** (`captionsetup`): 10pt, bold label, separated by a period.

Set `two-sided: false` for symmetric margins, no blank verso, and a fixed
header. `margin` overrides the geometry outright.

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
