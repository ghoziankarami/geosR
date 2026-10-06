#' Calculate Resources
#'
#' Calculates planar volume and grade content from aligned, single-layer rasters
#' in a projected metre CRS. Polygon intersections weight each cell by its exact
#' covered fraction; missing grade or thickness excludes the cell from all totals.
#'
#' @param raster_grade A single-layer SpatRaster of grade values.
#' @param raster_thickness An aligned single-layer SpatRaster of thickness in metres.
#' @param area An sf or sfc polygon boundary in the same projected metre CRS.
#' @param density A positive finite conversion factor (default 1). For grade in
#'   kg/m3 use 1; for mass-fraction grade and density in t/m3 the result is tonnes.
#'   Convert percentages to fractions before using that second convention.
#'
#' @return A list containing the per-cell content raster and a polygon table.
#'   Area is valid covered area in m2, volume is in m3, thickness is area-weighted,
#'   grade is volume-weighted, and metal_content sums covered per-cell content.
#'   Polygons without valid intersecting cells have zero totals and NA means.
#' @details Cell area is x resolution times y resolution. Area is measured in
#'   the map projection, not geodesic ground area; choose a suitable local CRS.
#'   The caller must supply compatible grade and density units. The result is
#'   preliminary numerical screening, not a reporting classification.
#' @importFrom dplyr group_by summarise left_join mutate select n
#' @export
calc_res <- function(raster_grade, raster_thickness, area, density = 1.0) {
  if (!inherits(raster_grade, "SpatRaster") ||
      !inherits(raster_thickness, "SpatRaster") ||
      terra::nlyr(raster_grade) != 1L || terra::nlyr(raster_thickness) != 1L) {
    stop("grade and thickness must be single-layer SpatRasters")
  }
  # compareGeom permits sub-cell offsets by default; aggregation needs aligned cells.
  if (!isTRUE(all.equal(as.vector(terra::ext(raster_grade)),
                        as.vector(terra::ext(raster_thickness)), tolerance = 1e-10))) {
    stop("grade and thickness extent must align")
  }
  terra::compareGeom(raster_grade, raster_thickness, stopOnError = TRUE)
  model_crs <- sf::st_crs(terra::crs(raster_grade))
  crs_units <- tolower(model_crs$units_gdal)
  if (is.na(model_crs) || terra::is.lonlat(raster_grade) || length(crs_units) != 1L ||
      !crs_units %in% c("metre", "meter", "metres", "meters", "m")) {
    stop("rasters require a projected CRS with metre units")
  }
  if (!inherits(area, c("sf", "sfc")) || is.na(sf::st_crs(area)) ||
      sf::st_crs(area) != model_crs) {
    stop("area must have the same projected metre CRS as the rasters")
  }
  if (!all(sf::st_geometry_type(area) %in% c("POLYGON", "MULTIPOLYGON"))) {
    stop("area must contain polygon geometry")
  }
  if (length(density) != 1L || !is.numeric(density) || !is.finite(density) || density <= 0) {
    stop("density must be a positive finite conversion factor")
  }
  cell_area <- prod(terra::res(raster_grade))
  tonnage_raster <- cell_area * raster_thickness * raster_grade * density
  values <- c(raster_grade, raster_thickness)
  names(values) <- c("grade", "thickness")
  covered <- terra::extract(values, terra::vect(area), exact = TRUE)
  valid <- is.finite(covered$grade) & is.finite(covered$thickness) &
    is.finite(covered$fraction) & covered$fraction > 0
  if (any(covered$thickness[valid] < 0)) stop("thickness must be non-negative")
  covered <- covered[valid, , drop = FALSE]
  summaries <- lapply(seq_len(length(sf::st_geometry(area))), function(id) {
    rows <- covered[covered$ID == id, , drop = FALSE]
    weights <- rows$fraction * cell_area
    volume <- weights * rows$thickness
    area_m2 <- sum(weights)
    volume_m3 <- sum(volume)
    content <- sum(volume * rows$grade) * density
    data.frame(ID = id, area_m2 = area_m2,
               avg_thickness_m = if (area_m2 > 0) volume_m3 / area_m2 else NA_real_,
               expected_volume_m3 = volume_m3,
               avg_grade = if (volume_m3 > 0) sum(volume * rows$grade) / volume_m3 else NA_real_,
               metal_content = content)
  })
  res_table <- if (length(summaries)) do.call(rbind, summaries) else
    data.frame(ID = integer(), area_m2 = numeric(), avg_thickness_m = numeric(),
               expected_volume_m3 = numeric(), avg_grade = numeric(), metal_content = numeric())
  list(raster = tonnage_raster, table = res_table)
}

#' Evaluate Resource Reconciliation
#'
#' Compares the calculated resource model against actual production (realization) values
#' to generate a recovery factor or "Koefisien Hasil".
#'
#' @param res_table A data.frame or tibble, typically the `table` output from `calc_res()`.
#' @param actual_production Numeric, the actual observed production values.
#'
#' @return The original resource table with appended columns for actual_production and recovery_factor.
#' @importFrom dplyr mutate
#' @export
ev_rest <- function(res_table, actual_production) {
  estimated_production <- sum(res_table$metal_content, na.rm = TRUE)
  recovery_factor <- actual_production / estimated_production
  
  res_table <- res_table |>
    dplyr::mutate(
      actual_production = actual_production,
      recovery_factor = round(recovery_factor, 4)
    )
  
  return(res_table)
}
#' Plot Resource Map
#'
#' Uses tmap to generate standardized spatial mapping plots, such as tonnage distribution over a block.
#'
#' @param tonnage_raster A SpatRaster representing the calculated metal content or resources per grid cell.
#' @param area An sf polygon outlining the resource boundary.
#' @param title Character, main title for the plot.
#' @param subtitle Character, subtitle or panel label content (e.g., total calculated resources).
#' @param col_palette Character, color palette for the raster mapping. Default is "Spectral".
#'
#' @return A tmap plot object suitable for viewing or export.
#' @importFrom tmap tm_shape tm_raster tm_borders tm_layout tm_grid tmap_mode tm_style
#' @importFrom RColorBrewer brewer.pal
#' @importFrom sf st_bbox
#' @export
plot_res <- function(tonnage_raster, area, title = "Resource Estimation", subtitle = "", col_palette = "Spectral") {
  tmap::tmap_mode("plot")
  col_pal <- rev(RColorBrewer::brewer.pal(3, col_palette))
  
  cell_area <- round(prod(terra::res(tonnage_raster)), 0)
  legend_title <- paste("Content / cell (", cell_area, "m2)")
  
  pmap <- tmap::tm_shape(tonnage_raster, bbox = sf::st_bbox(area)) +
    tmap::tm_raster(title = legend_title, style = "kmeans", alpha = 0.6, palette = col_pal) +
    tmap::tm_shape(area) + 
    tmap::tm_borders(col = "red", lwd = 2) +
    tmap::tm_style("white") + 
    tmap::tm_layout(
      main.title = title, 
      panel.labels = subtitle,
      panel.label.size = 1,
      main.title.position = "center",
      main.title.size = 1.2, 
      main.title.fontface = "bold",
      legend.position = c("right", "top"), 
      legend.outside = TRUE,
      legend.text.size = 0.8, 
      legend.bg.color = "white", 
      legend.frame = TRUE
    ) + 
    tmap::tm_grid(lines = FALSE, ticks = TRUE)
  
  return(pmap)
}
#' Back Transform Function from Gaussian distribution back to Normal
#' 
#' Originally written by Ashton Shortridge, May/June, 2008
#'
#' @param scores Numeric vector of normal scores to be back-transformed.
#' @param nscore A normal score object (typically from the `nscore()` function).
#' @param tails Character specifying extrapolation behavior for extreme values. Options:
#'   \itemize{
#'     \item \code{'none'}: No extrapolation; defaults back to initial min and max data.
#'     \item \code{'equal'}: Assumes symmetric distribution about the mean; scales linearly.
#'     \item \code{'separate'}: Calculates independent standard deviations for values above/below the mean.
#'   }
#' @param draw Logical; if TRUE, generates a plot of the transform function.
#'
#' @return A numeric vector of the back-transformed original values.
#' @importFrom stats sd approxfun
#' @export
backtr <- function(scores, nscore, tails='none', draw=TRUE) {
  
  mean_x <- mean(nscore$trn.table$x)
  sd_x <- stats::sd(nscore$trn.table$x)
  min_data <- min(nscore$trn.table$x)
  max_data <- max(nscore$trn.table$x)
  
  if(tails == 'separate') {
    small_x <- nscore$trn.table$x < mean_x
    large_x <- nscore$trn.table$x > mean_x
    
    small_sd <- sqrt(sum((nscore$trn.table$x[small_x] - mean_x)^2) / (length(nscore$trn.table$x[small_x]) - 1))
    large_sd <- sqrt(sum((nscore$trn.table$x[large_x] - mean_x)^2) / (length(nscore$trn.table$x[large_x]) - 1))
    
    min_x <- mean_x + (min(scores) * small_sd)
    max_x <- mean_x + (max(scores) * large_sd)
    
  } else if(tails == 'equal') {
    min_x <- mean_x + (min(scores) * sd_x)
    max_x <- mean_x + (max(scores) * sd_x)
    
  } else { # tails == 'none'
    min_x <- min_data
    max_x <- max_data
  }
  
  # Ensure we don't shrink inside the initial data boundaries when extrapolating
  if(tails != 'none') {
    if(min_x > min_data) { min_x <- min_data }
    if(max_x < max_data) { max_x <- max_data }
  }
  
  x <- c(min_x, nscore$trn.table$x, max_x)
  nsc <- c(min(scores), nscore$trn.table$nscore, max(scores))
  
  if(draw) { plot(nsc, x, main='Back-Transform Function') }
  
  back_xf <- stats::approxfun(nsc, x)
  val <- back_xf(scores)
  
  return(val)
}
#' Remove Outliers using IQR Method
#'
#' Cleans a numeric vector by removing extreme positive or negative outliers 
#' based on the Interquartile Range (IQR) method (Q1/Q3 +/- 1.5*IQR).
#' 
#' @param num Numeric vector to be cleaned.
#'
#' @return A numeric vector with the outliers removed.
#' @importFrom stats quantile IQR
#' @export
no_outlier <- function(num) {
  Q1 <- stats::quantile(num, 0.25, na.rm = TRUE)
  Q3 <- stats::quantile(num, 0.75, na.rm = TRUE)
  IQR <- stats::IQR(num, na.rm = TRUE)
  
  # Return data within the acceptable bounds
  no_out <- num[num >= (Q1 - 1.5 * IQR) & num <= (Q3 + 1.5 * IQR)]
  
  # Drop NAs implicitly introduced if vector had them
  return(no_out[!is.na(no_out)])
}
#' Gaussian Transformation (Normal Score)
#' 
#' Originally written by Ashton Shortridge, May/June, 2008.
#'
#' @param x Numeric vector to transform.
#'
#' @return A list containing:
#'   \item{nscore}{The normalized score vector.}
#'   \item{trn.table}{A data frame mapping the sorted original `x` values to the sorted `nscore` values.}
#' @importFrom stats qqnorm
#' @export
nscore <- function(x) {
  nscore_val <- stats::qqnorm(x, plot.it = FALSE)$x
  trn_table <- data.frame(x = sort(x), nscore = sort(nscore_val))
  
  return(list(nscore = nscore_val, trn.table = trn_table))
}
