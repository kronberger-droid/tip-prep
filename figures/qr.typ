// Repo QR, generated at compile time. Change `repo-url` and everything follows.
#import "@preview/codetastic:0.2.2": qrcode

#let repo-url = "https://doi.org/10.5281/zenodo.20325230"
#let repo-short = "doi.org/10.5281/zenodo.20325230"

#let repo-qr(width: 55mm) = qrcode(repo-url, width: width)
