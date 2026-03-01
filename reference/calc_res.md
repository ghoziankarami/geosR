# Calculate Resources

Calculates the volume, grade, and metal content (tonnage) for a resource
block. This calculation is generalized for any commodity, utilizing
geometric volume and grade block models.

## Usage

``` r
calc_res(raster_grade, raster_thickness, area, density = 1)
```

## Arguments

- raster_grade:

  A SpatRaster containing the estimated grade values.

- raster_thickness:

  A SpatRaster containing the estimated thickness values.

- area:

  An sf polygon outlining the resource calculation boundary.

- density:

  Numeric, the bulk density or specific gravity of the material (default
  = 1.0).

## Value

A list containing the `raster` of calculated metal content (tonnage) and
a `table` summarizing the area, expected volume, average grade, and
total metal content per polygon.
