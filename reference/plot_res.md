# Plot Resource Map

Uses tmap to generate standardized spatial mapping plots, such as
tonnage distribution over a block.

## Usage

``` r
plot_res(
  tonnage_raster,
  area,
  title = "Resource Estimation",
  subtitle = "",
  col_palette = "Spectral"
)
```

## Arguments

- tonnage_raster:

  A SpatRaster representing the calculated metal content or resources
  per grid cell.

- area:

  An sf polygon outlining the resource boundary.

- title:

  Character, main title for the plot.

- subtitle:

  Character, subtitle or panel label content (e.g., total calculated
  resources).

- col_palette:

  Character, color palette for the raster mapping. Default is
  "Spectral".

## Value

A tmap plot object suitable for viewing or export.
