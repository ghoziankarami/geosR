#' Removing Outliers Function
#'
#' this function using the IQR method for calculating outliers removal
#' @param Removing Outlier from Dataframe
#' @return Dataframe
#' @export
#'
no_outlier <- function(df, col){
  Q1 <- data.table::quantile(df$col, .25)
  Q3 <- data.table::quantile(df$col, .75)
  IQR <- data.table::IQR(df$col)
  no_outliers_data <- subset(df, df$col > (Q1 - 1.5*IQR) & df$col < (Q3 + 1.5*IQR))
}
