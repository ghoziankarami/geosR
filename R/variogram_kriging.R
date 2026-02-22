#' Fit a Variogram Model
#'
#' This function automates fitting a variogram model to a dataset given parameters,
#' suitable for various commodities and geological variables (e.g., grade, thickness).
#'
#' @param data An sf object containing the drillhole or sampling data.
#' @param formula A formula specifying the variable to model (e.g., grade ~ 1).
#' @param cutoff Numeric, the maximum distance for the variogram.
#' @param width Numeric, the lag width for the variogram.
#' @param model_type Character, the type of variogram model (default "Sph" for Spherical).
#' @param sill Numeric, the anisotropy sill or initial sill.
#' @param range Numeric, the model range.
#' @param anisotropy Numeric vector of length 2 representing the direction and anisotropy ratio.
#' @param tol_hor Numeric, horizontal tolerance angle (default: 22.5).
#'
#' @return A list containing the experimental directional variogram (`variogram`), 
#' the fitted variogram model (`model`), and the initial model parameters (`initial_model`).
#' @importFrom gstat variogram vgm fit.variogram
#' @rdname geostats
#' @export
fit_var <- function(data, formula, cutoff = 250, width = 50, model_type = "Sph", sill = 0.02, range = 150, anisotropy = c(45, 0.5), tol_hor = 22.5) {
  # Define the initial variogram model
  vm <- gstat::vgm(psill = sill, model = model_type, range = range, anis = anisotropy)
  
  # Calculate the experimental directional variogram
  vg_major <- gstat::variogram(formula, data, cutoff = cutoff, width = width, alpha = anisotropy[1], tol.hor = tol_hor)
  
  # Fit the model to the data
  fit <- gstat::fit.variogram(vg_major, vm, fit.sills = TRUE)
  
  return(list(variogram = vg_major, model = fit, initial_model = vm))
}

#' Estimate Ordinary Kriging
#'
#' Wraps around gstat::krige() to generate a kriging output over a specified 
#' sf grid bounds. This handles the spatial conversions automatically.
#'
#' @param data An sf object containing the drillhole data.
#' @param formula A formula specifying the variable to model (e.g., grade ~ 1).
#' @param grid An sf grid object over which to predict. Can be created using sf::st_make_grid().
#' @param vgm_model The fitted variogram model (typically the `model` output from `fit_var()`).
#' @param maxdist Numeric, maximum distance to look for data points.
#' @param nmin Numeric, minimum number of data points for an estimate.
#' @param omax Numeric, maximum number of data points per octant.
#'
#' @return An sf object containing the kriged predictions (`var1.pred`) and variances (`var1.var`).
#' @importFrom gstat krige
#' @rdname geostats
#' @export
est_krige <- function(data, formula, grid, vgm_model, maxdist = 300, nmin = 3, omax = 1) {
  kriged <- gstat::krige(formula, data, grid, model = vgm_model, maxdist = maxdist, nmin = nmin, omax = omax)
  return(kriged)
}
