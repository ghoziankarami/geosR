# Fit a Variogram Model

This function automates fitting a variogram model to a dataset given
parameters, suitable for various commodities and geological variables
(e.g., grade, thickness).

## Usage

``` r
fit_var(
  data,
  formula,
  cutoff = 250,
  width = 50,
  model_type = "Sph",
  sill = 0.02,
  range = 150,
  anisotropy = c(45, 0.5),
  tol_hor = 22.5
)
```

## Arguments

- data:

  An sf object containing the drillhole or sampling data.

- formula:

  A formula specifying the variable to model (e.g., grade ~ 1).

- cutoff:

  Numeric, the maximum distance for the variogram.

- width:

  Numeric, the lag width for the variogram.

- model_type:

  Character, the type of variogram model (default "Sph" for Spherical).

- sill:

  Numeric, the anisotropy sill or initial sill.

- range:

  Numeric, the model range.

- anisotropy:

  Numeric vector of length 2 representing the direction and anisotropy
  ratio.

- tol_hor:

  Numeric, horizontal tolerance angle (default: 22.5).

## Value

A list containing the experimental directional variogram (`variogram`),
the fitted variogram model (`model`), and the initial model parameters
(`initial_model`).
