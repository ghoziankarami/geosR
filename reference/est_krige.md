# Estimate Ordinary Kriging

Wraps around gstat::krige() to generate a kriging output over a
specified sf grid bounds. This handles the spatial conversions
automatically.

## Usage

``` r
est_krige(data, formula, grid, vgm_model, maxdist = 300, nmin = 3, omax = 1)
```

## Arguments

- data:

  An sf object containing the drillhole data.

- formula:

  A formula specifying the variable to model (e.g., grade ~ 1).

- grid:

  An sf grid object over which to predict. Can be created using
  sf::st_make_grid().

- vgm_model:

  The fitted variogram model (typically the `model` output from
  [`fit_var()`](https://ghoziankarami.github.io/geosR/reference/fit_var.md)).

- maxdist:

  Numeric, maximum distance to look for data points.

- nmin:

  Numeric, minimum number of data points for an estimate.

- omax:

  Numeric, maximum number of data points per octant.

## Value

An sf object containing the kriged predictions (`var1.pred`) and
variances (`var1.var`).
