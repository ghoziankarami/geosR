# Calculate Resources

Calculates planar volume and grade content from aligned, single-layer
rasters in a projected metre CRS. Polygon intersections weight each cell
by its exact covered fraction; missing grade or thickness excludes the
cell from all totals.

## Usage

``` r
calc_res(raster_grade, raster_thickness, area, density = 1)
```

## Arguments

- raster_grade:

  A single-layer SpatRaster of grade values.

- raster_thickness:

  An aligned single-layer SpatRaster of thickness in metres.

- area:

  An sf or sfc polygon boundary in the same projected metre CRS.

- density:

  A positive finite conversion factor (default 1). For grade in kg/m3
  use 1; for mass-fraction grade and density in t/m3 the result is
  tonnes. Convert percentages to fractions before using that second
  convention.

## Value

A list containing the per-cell content raster and a polygon table. Area
is valid covered area in m2, volume is in m3, thickness is
area-weighted, grade is volume-weighted, and metal_content sums covered
per-cell content. Polygons without valid intersecting cells have zero
totals and NA means.

## Details

Cell area is x resolution times y resolution. Area is measured in the
map projection, not geodesic ground area; choose a suitable local CRS.
The caller must supply compatible grade and density units. The result is
preliminary numerical screening, not a reporting classification.
