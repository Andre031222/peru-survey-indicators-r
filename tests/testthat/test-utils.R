test_that("errors and warnings carry their kind", {
  expect_error(faperu.analysis:::.abort("x", "a %s", "b"), "a b", class = "fpa_error_x")
  expect_warning(faperu.analysis:::.warn("y", "z"), class = "fpa_warning_y")
})

test_that("codes are padded and columns found ignoring case", {
  expect_equal(faperu.analysis:::.pad(c(1, 15, NA), 2), c("01", "15", NA))
  expect_equal(faperu.analysis:::.col(data.frame(UBIGEO = 1), "ubigeo"), "UBIGEO")
  expect_null(faperu.analysis:::.col(data.frame(a = 1), "b"))
})
