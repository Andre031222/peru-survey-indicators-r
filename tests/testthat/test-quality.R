test_that("CV bands follow INEI cut points", {
  expect_equal(fpa_quality(c(0, 4.99, 5, 9.9, 10, 15, 15.1, NA)),
               c("muy buena", "muy buena", "buena", "buena", "aceptable", "referencial",
                 "referencial", NA))
  expect_error(fpa_quality("5"), class = "fpa_error_bad_input")
})
