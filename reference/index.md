# Package index

## Resource Calculation & Evaluation

Core tools for computing block volumes, applying density parameters,
evaluating recovery factors against realization, and plotting resource
maps.

- [`calc_res()`](https://ghoziankarami.github.io/geosR/reference/calc_res.md)
  : Calculate Resources
- [`ev_rest()`](https://ghoziankarami.github.io/geosR/reference/ev_rest.md)
  : Evaluate Resource Reconciliation
- [`plot_res()`](https://ghoziankarami.github.io/geosR/reference/plot_res.md)
  : Plot Resource Map

## Geostatistical Spatial Modeling

Wrappers around gstat to streamline generating experimental variograms,
fitting spherical models, and executing Ordinary Kriging.

- [`fit_var()`](https://ghoziankarami.github.io/geosR/reference/fit_var.md)
  : Fit a Variogram Model
- [`est_krige()`](https://ghoziankarami.github.io/geosR/reference/est_krige.md)
  : Estimate Ordinary Kriging

## Statistical Extrapolation & Transformation

Data preparation helpers for transforming gaussian data, cleaning
outliers, and calculating normal scores.

- [`backtr()`](https://ghoziankarami.github.io/geosR/reference/backtr.md)
  : Back Transform Function from Gaussian distribution back to Normal
- [`no_outlier()`](https://ghoziankarami.github.io/geosR/reference/no_outlier.md)
  : Remove Outliers using IQR Method
- [`nscore()`](https://ghoziankarami.github.io/geosR/reference/nscore.md)
  : Gaussian Transformation (Normal Score)
