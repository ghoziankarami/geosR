#' Removing Outliers Function
#'
#' this function using the IQR method for calculating outliers removal
#' @param num Numeric
#' @export
#'
no_outlier <- function(num) {
  Q1 <- stats::quantile(num, .25)
  Q3 <- stats::quantile(num, .75)
  IQR <- stats::IQR(num)
  x <- as.data.frame(num)
  no_out <- subset(x, num > (Q1 - 1.5*IQR) & num < (Q3 + 1.5*IQR))
  return(no_out)
}
