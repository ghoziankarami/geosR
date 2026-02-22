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
