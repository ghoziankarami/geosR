# geosR

**geosR** is an R package containing generalized functional wrappers for
resource estimation, exploratory data analysis, and kriging. It
simplifies the pipeline from drillhole points to evaluated resource
tonnages by wrapping `gstat`, `sf`, and `terra` together under
best-practice standard names.

## Key Features

- **Spatial Modeling (`fit_var`, `est_krige`)**: Easily fit variograms
  to your raw geoscientific point data and generate interpolated block
  models.
- **Resource Evaluation (`calc_res`, `ev_rest`)**: Spatially intersect
  block models with boundaries, calculate metric volume, configure
  density adjustments for arbitrary commodities, and evaluate
  reconciliation recovery factors.
- **Mapping (`plot_res`)**: Leverage built-in `tmap` configurations to
  generate presentation-ready spatial maps.
- **Statistical Helpers (`backtr`, `nscore`, `no_outlier`)**: Transform
  and analyze data distributions directly.

## Installation

You can install the development version of geosR directly from GitHub:

``` r
# Install devtools if you haven't already
# install.packages("devtools")

devtools::install_github("ghoziankarami/geosR", build_vignettes = TRUE)
```

## Documentation & Tutorials

The core of this package is documented through interactive vignettes and
function manuals.

Since this package utilizes GitHub Actions for automated documentation,
you can browse the **interactive tutorial online:** [👉 geosR GitHub
Pages site](https://ghoziankarami.github.io/geosR/)

You can also read the vignette directly inside your R session after
installation:

``` r
library(geosR)
vignette("geosR_tutorial")
```
