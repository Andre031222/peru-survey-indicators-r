tab <- data.frame(name = c("Lima", "Ica"), estimate = c(.27, .06), se = c(.012, .009),
                  ci_low = c(.246, .042), ci_high = c(.294, .078), cv = c(4.5, 15.6),
                  n = c(5000, 900), official = c(NA, .061))

test_that("the data frame shows percent, CI and the low-precision mark", {
  r <- fpa_table(tab)
  expect_equal(r$Estimate, c("27.0", "6.0*"))
  expect_equal(r$`95% CI`, c("24.6 - 29.4", "4.2 - 7.8"))
  expect_equal(r$n, c("5,000", "900"))
  expect_equal(r$INEI, c("", "6.1"))
  expect_match(attr(r, "note"), "referencial")
  expect_equal(fpa_table(tab, percent = FALSE, digits = 2)$Estimate[1], "0.27")
})

test_that("markdown and LaTeX come out as lines", {
  md <- fpa_table(tab, format = "markdown", caption = "Poverty")
  expect_equal(md[1], "Table: Poverty")
  expect_true(any(grepl("^\\| Lima \\| 27.0 \\|", md)))
  tex <- fpa_table(tab, format = "latex")
  expect_true(any(grepl("CV \\(\\\\%\\)", tex)))
  expect_equal(tex[length(tex)], "\\end{table}")
})

test_that("non-estimate tables are refused", {
  expect_error(fpa_table(data.frame(a = 1)), class = "fpa_error_bad_input")
})
