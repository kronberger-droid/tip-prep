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

`report()` takes `title`, `institution`, `faculty`, `course`, `document-type`,
`authors`, `supervisor`, `groupnumber`, `date`, `date-format`, `running-header`
and `language`.

Every text field accepts either a string or content, so `title: [ Conditioning
of _SPM_ Tips ]` works, as does a content entry in the `authors` array.

`document-type` is the bold line between the rules, `[Report]` by default.
Passing `none` for it, or for `course`, `supervisor` or `groupnumber`, omits that
block entirely. `running-header` defaults to the title. A `datetime` `date` is
formatted with `date-format`; any other value is printed as given, so
`date: [Summer term 2026]` is valid.

## License

[MIT](LICENSE)
