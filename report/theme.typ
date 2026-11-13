// Colours of the report, in one place.
//
// The default is the printed report: black on white, as before. Compile with
// `--input theme=dark` for a screen version on the base16 palette below:
//
//     typst compile --input theme=dark main.typ main-dark.pdf
//
// Nothing in the chapters or figures names a colour directly. They go through
// the roles here, so the light output stays what it was and the dark one
// follows the palette. Bitmap figures (the scan images, the workbench
// screenshot) are not recoloured. The run figure is drawn in ../figures,
// which writes a second copy in these colours for the dark output.

#let dark = sys.inputs.at("theme", default: "light") == "dark"

// The base16 scheme. Edit the values to retheme the dark output; the slots
// keep their usual base16 meaning.
#let base16 = (
  base00: rgb("1e1e1e"), // background
  base01: rgb("2c2f33"), // lighter background
  base02: rgb("373c45"), // selection
  base03: rgb("555555"), // comments
  base04: rgb("c0c5ce"), // dark foreground
  base05: rgb("dfe1e8"), // foreground
  base06: rgb("eff0f1"), // light foreground
  base07: rgb("f5f5f5"), // light background
  base08: rgb("ac4142"), // red
  base09: rgb("ac4142"), // orange slot, kept red
  base0A: rgb("e5b566"), // yellow
  base0B: rgb("7e8d50"), // green
  base0C: rgb("6fb3ad"), // cyan
  base0D: rgb("6c99ba"), // blue
  base0E: rgb("9e4e85"), // magenta
  base0F: rgb("8a8177"), // brown
)

// Paper and ink.
#let paper = if dark { base16.base00 } else { white }
#let ink = if dark { base16.base05 } else { black }

// The accent of the diagrams, and the two apex states that have a colour of
// their own.
#let accent = if dark { base16.base0D } else { rgb("0267A5") }
#let blunt = if dark { base16.base08 } else { rgb("B0533A") }
#let stable = if dark { base16.base0B } else { rgb("2E7D32") }
// Draft marks and review notes.
#let todo-color = if dark { base16.base0E } else { rgb("8E24AA") }
#let note-color = if dark { base16.base0D } else { rgb("1E88E5") }
// Text set on a fill of `accent`, `blunt` or `stable`.
#let on-fill = if dark { base16.base00 } else { white }

// A grey between ink (0) and paper (255), where the light report says
// `luma(n)`: `grey(90)` for secondary text, `grey(240)` for a quiet fill.
#let grey(n) = if dark {
  color.mix((paper, n * 1%), (ink, (255 - n) * 1%))
} else {
  luma(n)
}

// A colour faded toward the paper, where the light report says
// `c.lighten(p)`.
#let tint(c, p) = if dark { color.mix((c, 100% - p), (paper, p)) } else { c.lighten(p) }
// A colour pushed toward the ink, where the light report says `c.darken(p)`:
// on dark paper a stroke or label has to get lighter to stand out.
#let shade(c, p) = if dark { color.mix((c, 100% - p), (ink, p)) } else { c.darken(p) }

// Syntax colours for code listings in the dark output, as a TextMate theme
// built from the palette. The light output keeps Typst's own.
#let raw-theme = if dark {
  let hex(c) = c.to-hex()
  let rule(scope, c) = (
    "<dict><key>scope</key><string>" + scope + "</string><key>settings</key><dict>"
      + "<key>foreground</key><string>" + hex(c) + "</string>"
      + "</dict></dict>"
  )
  let b = base16
  bytes(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><plist version=\"1.0\"><dict>"
      + "<key>name</key><string>report-dark</string><key>settings</key><array>"
      + "<dict><key>settings</key><dict>"
      + "<key>background</key><string>" + hex(b.base00) + "</string>"
      + "<key>foreground</key><string>" + hex(b.base05) + "</string>"
      + "</dict></dict>"
      + rule("comment", b.base03.lighten(25%))
      + rule("string, string.quoted", b.base0B)
      + rule("constant.numeric, constant.language, constant.character", b.base0A)
      + rule("keyword, storage, storage.type, storage.modifier", b.base0E.lighten(25%))
      + rule("entity.name.function, support.function, meta.function-call", b.base0D)
      + rule("entity.name.type, entity.name.class, support.type, entity.name.trait", b.base0C)
      + rule("variable.language, variable.parameter", b.base08.lighten(25%))
      + rule("meta.attribute, meta.annotation, punctuation.definition.annotation", b.base0F)
      + "</array></dict></plist>",
  )
}

// A figure made outside the report has a second file for the dark output,
// named with `-dark` before the extension: `variant("fig_run.pdf")` is
// `fig_run-dark.pdf` there and the name itself on paper.
#let variant(path) = if dark { path.replace(regex("(\.[a-z]+)$"), m => "-dark" + m.text) } else { path }
