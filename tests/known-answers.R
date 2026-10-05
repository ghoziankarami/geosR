library(geosR)

# Three distinct observations: the middle value has Gaussian score zero.
x <- c(30, 10, 20)
transformed <- nscore(x)
expected <- qnorm(c(2.625, 0.625, 1.625) / 3.25)
stopifnot(isTRUE(all.equal(transformed$nscore, expected, tolerance = 1e-10)))
stopifnot(identical(transformed$trn.table$x, sort(x)))

# IQR filtering excludes a large outlier and missing values.
stopifnot(identical(no_outlier(c(1:10, 100, NA_real_)), as.numeric(1:10)))

# Independent reconciliation arithmetic: 40 actual / (50 + 30) model = 0.5.
table <- data.frame(ID = c("A", "B"), metal_content = c(50, 30))
result <- ev_rest(table, actual_production = 40)
stopifnot(all(result$recovery_factor == 0.5))
stopifnot(all(result$actual_production == 40))
stopifnot(identical(result$metal_content, table$metal_content))
