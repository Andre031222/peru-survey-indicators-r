est <- function(domain, estimate, by = "department", cv = 3, year = 2024) {
  data.frame(by = by, domain = domain, estimate = estimate, se = estimate * cv / 100,
             cv = cv, n = 100, quality = fpa_quality(cv), year = year, stringsAsFactors = FALSE)
}

test_that("departments join by code and year", {
  a <- est(c("01", "02", "15"), c(.3, .4, .2))
  b <- est(c("01", "15"), c(.5, .6))
  r <- fpa_link(pov = a, women = b)
  expect_equal(r$department, c("01", "15"))
  expect_equal(r$name, c("Amazonas", "Lima"))
  expect_equal(r$estimate_pov, c(.3, .2))
  expect_equal(r$estimate_women, c(.5, .6))
  expect_equal(nrow(fpa_link(pov = a, women = b, all = TRUE)), 3)
})

test_that("different years only join when asked", {
  a <- est("01", .3, year = 2023)
  b <- est("01", .5)
  expect_warning(r <- fpa_link(a = a, b = b), class = "fpa_warning_no_match")
  expect_equal(nrow(r), 0)
  r <- fpa_link(a = a, b = b, by_year = FALSE)
  expect_equal(r$year_a, 2023)
  expect_equal(r$year_b, 2024)
})

test_that("low precision is flagged", {
  a <- est(c("01", "02"), c(.3, .4), cv = c(20, 3))
  expect_warning(fpa_link(a = a, b = est("01", .1)), class = "fpa_warning_low_precision")
})

test_that("districts move to the 2017 frame", {
  # 080918 (Union Ashaninka) split from 080910 (Pichari) after 2017.
  a <- est(c("080910", "080918", "010101"), c(.3, .5, .2), by = "district")
  b <- est(c("080910", "010101"), c(.6, .7), by = "district")
  expect_warning(r <- fpa_link(a = a, b = b, level = "district"), class = "fpa_warning_merged_districts")
  expect_equal(r$ubigeo_base, c("010101", "080910"))
  expect_equal(r$estimate_a, c(.2, .3))
  m <- est(c("090724", "010101"), c(.3, .2), by = "district")
  expect_warning(fpa_link(m = m, b = b, level = "district"), class = "fpa_warning_multi_parent")
})

test_that("bad tables are refused", {
  a <- est("01", .3)
  expect_error(fpa_link(a), class = "fpa_error_bad_input")
  expect_error(fpa_link(a, a), class = "fpa_error_bad_input")
  expect_error(fpa_link(a = a, b = data.frame(x = 1)), class = "fpa_error_bad_input")
  expect_error(fpa_link(a = a, b = a, level = "district"), class = "fpa_error_bad_input")
  expect_error(fpa_link(a = a, b = a[, -8]), class = "fpa_error_bad_input")
})

test_that("poverty and women producers link by department with real data", {
  skip_if_no_local()
  p <- fpa_indicator("pobreza_monetaria", 2024, by = "department", cache = local_root())
  w <- fpa_indicator("mujeres_productoras", 2024, by = "department", cache = local_root())
  r <- suppressWarnings(fpa_link(poverty = p, women = w))
  expect_gte(nrow(r), 24)
  expect_true(all(c("estimate_poverty", "estimate_women", "quality_women") %in% names(r)))
})
