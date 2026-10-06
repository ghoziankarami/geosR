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

# Two rectangular 10 x 20 m cells. Volume = 200*1 + 200*3 = 800 m3;
# content = 200*1*1 + 200*3*3 = 2000, not product-of-means 1600.
grade <- terra::rast(nrows = 1, ncols = 2, xmin = 0, xmax = 20,
                     ymin = 0, ymax = 20, crs = "EPSG:3857")
terra::values(grade) <- c(1, 3)
thickness <- grade
terra::values(thickness) <- c(1, 3)
boundary <- function(xmin, xmax, ymin = 0, ymax = 20) {
  coordinates <- rbind(c(xmin, ymin), c(xmax, ymin), c(xmax, ymax),
                       c(xmin, ymax), c(xmin, ymin))
  sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(coordinates)), crs = 3857))
}
near <- function(actual, expected) stopifnot(isTRUE(all.equal(actual, expected, tolerance = 1e-8)))
whole <- calc_res(grade, thickness, boundary(0, 20))
near(whole$table$area_m2, 400)
near(whole$table$expected_volume_m3, 800)
near(whole$table$avg_thickness_m, 2)
near(whole$table$avg_grade, 2.5)
near(whole$table$metal_content, 2000)
near(as.numeric(terra::values(whole$raster)), c(200, 1800))
near(sum(terra::values(whole$raster)), whole$table$metal_content)

# Clip half the first cell and all the second: valid area 300, volume 700,
# content 100*1*1 + 200*3*3 = 1900, volume-weighted grade 19/7.
partial <- calc_res(grade, thickness, boundary(5, 20))
near(partial$table$area_m2, 300)
near(partial$table$expected_volume_m3, 700)
near(partial$table$avg_grade, 19/7)
near(partial$table$metal_content, 1900)
near(calc_res(grade, thickness, boundary(0, 20), density = 2)$table$metal_content, 4000)

# Pairwise missingness: a thickness observation without grade is excluded.
missing_grade <- grade
terra::values(missing_grade) <- c(NA_real_, 3)
missing <- calc_res(missing_grade, thickness, boundary(0, 20))
near(missing$table$area_m2, 200)
near(missing$table$expected_volume_m3, 600)
near(missing$table$metal_content, 1800)
near(missing$table$avg_thickness_m, 3)
empty <- calc_res(grade, thickness, boundary(30, 40))
near(empty$table$area_m2, 0)
near(empty$table$metal_content, 0)
stopifnot(is.na(empty$table$avg_grade), is.na(empty$table$avg_thickness_m))

# A zero-thickness region has zero volume/content and undefined average grade.
zero_thickness <- thickness * 0
zero <- calc_res(grade, zero_thickness, boundary(0, 20))
near(zero$table$expected_volume_m3, 0)
near(zero$table$metal_content, 0)
stopifnot(is.na(zero$table$avg_grade))

expect_error <- function(expression, pattern) {
  message <- tryCatch({ force(expression); "" }, error = function(e) conditionMessage(e))
  stopifnot(grepl(pattern, message))
}
expect_error(calc_res(grade, thickness, boundary(0, 20), density = -1), "density")
expect_error(calc_res(grade, thickness, boundary(0, 20), density = Inf), "density")
bad_thickness <- thickness * -1
expect_error(calc_res(grade, bad_thickness, boundary(0, 20)), "thickness")
expect_error(calc_res(grade, terra::shift(thickness, dx = 1), boundary(0, 20)), "extent")
degrees <- grade
terra::crs(degrees) <- "EPSG:4326"
expect_error(calc_res(degrees, degrees, sf::st_transform(boundary(0, 20), 4326)), "metre")
feet <- grade
terra::crs(feet) <- "EPSG:2263"
expect_error(calc_res(feet, feet, sf::st_transform(boundary(0, 20), 2263)), "metre")
expect_error(calc_res(grade, thickness, sf::st_transform(boundary(0, 20), 4326)), "same")
