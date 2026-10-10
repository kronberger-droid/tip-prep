// Request and response frames of the Nanonis TCP protocol, after
// nanonis-rs docs/tcp-protocol.md (R14718), sections Request message and
// Response message. Field widths are not to scale.
#let frame-diagram(accent: rgb("0267A5")) = {
  set text(size: 8pt)
  set par(justify: false)

  let head = accent.lighten(85%)
  let body = luma(238)
  let err = rgb("B0533A").lighten(80%)

  let field(name, size, fill) = table.cell(fill: fill, align(center)[
    #name \ #text(size: 0.85em, fill: luma(90))[#size]
  ])

  let row(label, ..cells) = (
    table.cell(stroke: none, align: right + horizon, text(weight: "bold", label)),
    ..cells.pos(),
  )

  table(
    columns: (auto, 3fr, 1fr, 1fr, 1fr, 2.4fr, 1fr, 1fr, 1.6fr),
    stroke: 0.6pt + accent,
    inset: 4pt,
    ..row(
      [Request],
      field([command name], [32 B, zero-padded], head),
      field([body size], [4 B], head),
      field([response flag], [2 B], head),
      field([unused], [2 B], head),
      table.cell(colspan: 4, fill: body, align: center + horizon)[arguments, typed per command],
    ),
    ..row(
      [Response],
      field([command name], [32 B, zero-padded], head),
      field([body size], [4 B], head),
      table.cell(colspan: 2, fill: head, align(center)[unused \ #text(size: 0.85em, fill: luma(90))[4 B]]),
      field([return values], [typed per command], body),
      field([error status], [4 B], err),
      field([description size], [4 B], err),
      field([description], [variable], err),
    ),
  )
}
