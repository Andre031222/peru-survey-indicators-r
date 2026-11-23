test_that("an empty population is refused", {
  expect_error(faperu.analysis:::.design(data.frame(), "enaho"), class = "fpa_error_empty")
})

test_that("department domains work on a real indicator", {
  skip_if_no_local()
  r <- fpa_indicator("pobreza_monetaria", 2024, by = "department", cache = local_root())
  expect_equal(nrow(r), 25)
  expect_true(all(r$estimate > 0 & r$estimate < 1))
  expect_true(all(r$quality %in% c("muy buena", "buena", "aceptable", "referencial")))
})
