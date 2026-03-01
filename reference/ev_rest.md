# Evaluate Resource Reconciliation

Compares the calculated resource model against actual production
(realization) values to generate a recovery factor or "Koefisien Hasil".

## Usage

``` r
ev_rest(res_table, actual_production)
```

## Arguments

- res_table:

  A data.frame or tibble, typically the `table` output from
  [`calc_res()`](https://ghoziankarami.github.io/geosR/reference/calc_res.md).

- actual_production:

  Numeric, the actual observed production values.

## Value

The original resource table with appended columns for actual_production
and recovery_factor.
