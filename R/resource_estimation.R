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
