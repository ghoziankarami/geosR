#' Calculate Resources
#'
#' Calculates the volume, grade, and metal content (tonnage) for a resource block. 
#' This calculation is generalized for any commodity, utilizing geometric volume 
#' and grade block models.
#'
#' @param raster_grade A SpatRaster containing the estimated grade values.
#' @param raster_thickness A SpatRaster containing the estimated thickness values.
#' @param area An sf polygon outlining the resource calculation boundary.
#' @param density Numeric, the bulk density or specific gravity of the material (default = 1.0).
#'
#' @return A list containing the `raster` of calculated metal content (tonnage) 
#' and a `table` summarizing the area, expected volume, average grade, and total metal content per polygon.
#' @importFrom terra extract xres
#' @importFrom dplyr group_by summarise left_join mutate select n
#' @rdname calculators
#' @export
calc_res <- function(raster_grade, raster_thickness, area, density = 1.0) {
  # Calculate dimensions of a single cell
  cell_area <- terra::xres(raster_grade)^2
  
  # Calculate tonnage per cell = cell area * thickness * grade * density
  # (assuming grade is in mass/volume e.g., kg/m3. Or adjust density parameter if volume grade is dimensionless).
  tonnage_raster <- cell_area * raster_thickness * raster_grade * density
  
  # Calculate area per polygon
  area_val <- terra::extract(tonnage_raster, area)
  luasan_polygon <- area_val |>
    dplyr::group_by(ID) |>
    dplyr::summarise(area_m2 = dplyr::n() * cell_area)
  
  # Calculate average thickness per polygon
  thickness_val <- terra::extract(raster_thickness, area, fun = mean, na.rm = TRUE)
  thickness_polygon <- data.frame(ID = thickness_val[, 1], avg_thickness_m = thickness_val[, 2])
  
  # Calculate average grade per polygon
  grade_val <- terra::extract(raster_grade, area, fun = mean, na.rm = TRUE)
  grade_polygon <- data.frame(ID = grade_val[, 1], avg_grade = grade_val[, 2])
  
  # Join all summaries together
  res_table <- dplyr::left_join(thickness_polygon, grade_polygon, by = "ID") |>
    dplyr::left_join(luasan_polygon, by = "ID") |>
    dplyr::mutate(
      expected_volume_m3 = area_m2 * avg_thickness_m,
      metal_content = expected_volume_m3 * avg_grade * density
    ) |>
    dplyr::select(ID, area_m2, avg_thickness_m, expected_volume_m3, avg_grade, metal_content)
  
  return(list(raster = tonnage_raster, table = res_table))
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
#' @rdname calculators
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
#' @rdname calculators
#' @export
plot_res <- function(tonnage_raster, area, title = "Resource Estimation", subtitle = "", col_palette = "Spectral") {
  tmap::tmap_mode("plot")
  col_pal <- rev(RColorBrewer::brewer.pal(3, col_palette))
  
  cell_area <- round(terra::xres(tonnage_raster)^2, 0)
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
#' @rdname estimators
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
#' @rdname estimators
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
#' @rdname estimators
#' @export
nscore <- function(x) {
  nscore_val <- stats::qqnorm(x, plot.it = FALSE)$x
  trn_table <- data.frame(x = sort(x), nscore = sort(nscore_val))
  
  return(list(nscore = nscore_val, trn.table = trn_table))
}
