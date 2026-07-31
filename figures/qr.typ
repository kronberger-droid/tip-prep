// Repo QR code, generated natively at compile time.
//
// `codetastic` draws the QR as vector graphics, so it stays crisp at A0 and
// there is no PNG asset to keep in sync with the URL. Change `repo-url` here
// and the code regenerates; nothing else needs touching.
//
// Verified: OpenCV's QRCodeDetector decodes the rendered output back to
// `repo-url`. It comes out as a version-7 symbol (43x43 modules), which is
// larger than the minimum for this URL, so keep it physically big. At the
// 58 mm used on the poster each module is ~1.3 mm, comfortably above the
// ~0.4 mm print floor.
//
// STILL SCAN THE PRINTED PROOF WITH A PHONE. A QR that only ever existed as a
// PDF is an untested QR.

#import "@preview/codetastic:0.2.2": qrcode

#let repo-url = "https://doi.org/10.5281/zenodo.20325230"
#let repo-short = "doi.org/10.5281/zenodo.20325230"

#let repo-qr(width: 55mm) = qrcode(repo-url, width: width)
