# Back Transform Function from Gaussian distribution back to Normal

Originally written by Ashton Shortridge, May/June, 2008

## Usage

``` r
backtr(scores, nscore, tails = "none", draw = TRUE)
```

## Arguments

- scores:

  Numeric vector of normal scores to be back-transformed.

- nscore:

  A normal score object (typically from the
  [`nscore()`](https://ghoziankarami.github.io/geosR/reference/nscore.md)
  function).

- tails:

  Character specifying extrapolation behavior for extreme values.
  Options:

  - `'none'`: No extrapolation; defaults back to initial min and max
    data.

  - `'equal'`: Assumes symmetric distribution about the mean; scales
    linearly.

  - `'separate'`: Calculates independent standard deviations for values
    above/below the mean.

- draw:

  Logical; if TRUE, generates a plot of the transform function.

## Value

A numeric vector of the back-transformed original values.
