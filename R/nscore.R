#' Gaussian Transformation, written by Ashton Shortridge, May/June, 2008
#'
#' @param x Numeric
#' @export
#'

nscore <- function(x) {                        #
  nscore <- qqnorm(x, plot.it = FALSE)$x  # normal score
  trn.table <- data.frame(x=sort(x),nscore=sort(nscore))
  return (list(nscore=nscore, trn.table=trn.table))
}
