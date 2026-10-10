// Helper functions for data analysis, carried over from the labor-III reports.
// Add parsing routines for your own data format here.

#import calc: pow, sqrt

// An open question or missing source in the draft, in the poster's
// blunt-red. Grep for `todo[` before handing the report in.
#let todo(body) = text(fill: rgb("B0533A"), weight: "semibold")[[#body]]

#let mean(xs) = xs.sum() / xs.len()

// Sample standard deviation (Bessel-corrected).
#let stddev(xs) = {
  let m = mean(xs)
  sqrt(xs.map(x => pow(x - m, 2)).sum() / (xs.len() - 1))
}

// Standard error of the mean.
#let stderr(xs) = stddev(xs) / sqrt(xs.len())

// Unweighted least-squares fit of y = k*x + d.
// Returns a dictionary (slope, intercept).
#let linear-fit(xs, ys) = {
  let n = xs.len()
  let sum-x = xs.sum()
  let sum-y = ys.sum()
  let sum-xy = xs.zip(ys).map(p => p.at(0) * p.at(1)).sum()
  let sum-x2 = xs.map(x => x * x).sum()
  let slope = (n * sum-xy - sum-x * sum-y) / (n * sum-x2 - sum-x * sum-x)
  (
    slope: slope,
    intercept: (sum-y - slope * sum-x) / n,
  )
}
