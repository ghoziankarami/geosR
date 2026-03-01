# Remove Outliers using IQR Method

Cleans a numeric vector by removing extreme positive or negative
outliers based on the Interquartile Range (IQR) method (Q1/Q3 +/-
1.5\*IQR).

## Usage

``` r
no_outlier(num)
```

## Arguments

- num:

  Numeric vector to be cleaned.

## Value

A numeric vector with the outliers removed.
