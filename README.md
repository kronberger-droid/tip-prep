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

## Template parameters

The title page follows the LaTeX front page from
[thesis-bachelor](https://github.com/kronberger-droid/thesis-bachelor)
(`src/00_intro/title.tex`), ported to Typst.

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
| `groupnumber`, `running-header`, `language` | `running-header` defaults to the title. |

Every text field accepts either a string or content, so `title: [ Conditioning
of _SPM_ Tips ]` works, as does a content entry in `authors` or `advisors`.
Passing `none` omits a block entirely rather than leaving a gap.

## License

[MIT](LICENSE)
