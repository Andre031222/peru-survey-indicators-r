test_that("the package loads with its help page", {
  expect_true("fpa_estimate" %in% getNamespaceExports("faperu.analysis"))
})
