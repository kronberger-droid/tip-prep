#import "report.typ": report
#import "lib.typ": *
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/unify:0.8.1": num, qty

#show: report.with(
  title: "Tip Preparation",
  authors: ("Martin Kronberger",),
  supervisor: none,
  date: datetime.today(),
)

= Introduction

= Experimental Setup

#figure(
  image("assets/tuw_logo.jpg", width: 40%),
  caption: [Placeholder — replace with the setup diagram.],
) <fig:setup>

= Results

= Discussion

#bibliography("refs.bib", style: "american-physics-society")
