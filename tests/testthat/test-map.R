squares <- function(codes) {
  polys <- lapply(seq_along(codes), function(i) {
    sf::st_polygon(list(rbind(c(i, 0), c(i + 1, 0), c(i + 1, 1), c(i, 1), c(i, 0))))
  })
  sf::st_sf(code = codes, name = codes, geometry = sf::st_sfc(polys, crs = 4326))
}

test_that("estimates are drawn by department", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  x <- data.frame(by = "department", domain = c("01", "15"), estimate = c(.2, .4))
  p <- fpa_map(x, geometry = squares(c("01", "15", "02")))
  expect_s3_class(p, "ggplot")
  expect_equal(p$data$fpa_fill, c(.2, .4, NA))
  expect_warning(fpa_map(rbind(x, data.frame(by = "department", domain = "99", estimate = 1)),
                         geometry = squares(c("01", "15"))), class = "fpa_warning_not_on_map")
})

test_that("district boundaries merge into the 2017 frame", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  g <- squares(c("080910", "080918", "010101"))
  x <- data.frame(ubigeo_base = c("080910", "010101"), estimate = c(.3, .1))
  p <- fpa_map(x, level = "district", base = 2017, geometry = g)
  expect_setequal(p$data$code, c("080910", "010101"))
  expect_equal(p$data$fpa_fill[p$data$code == "080910"], .3)
})

test_that("bad input is refused", {
  skip_if_not_installed("sf")
  skip_if_not_installed("ggplot2")
  g <- squares("01")
  x <- data.frame(domain = "01", estimate = .2, txt = "a")
  expect_error(fpa_map(x, "nope", geometry = g), class = "fpa_error_not_found")
  expect_error(fpa_map(x, "txt", geometry = g), class = "fpa_error_bad_input")
  expect_error(fpa_map(list(), geometry = g), class = "fpa_error_bad_input")
  expect_error(fpa_map(rbind(x, x), geometry = g), class = "fpa_error_bad_input")
  expect_error(fpa_map(x, geometry = data.frame(code = "01")), class = "fpa_error_bad_input")
})

test_that("missing packages give a clear error", {
  expect_error(faperu.analysis:::.need("surely.not.a.package", "for maps"),
               "install.packages", class = "fpa_error_missing_package")
})
