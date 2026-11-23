api_design <- function() {
  data(api, package = "survey", envir = environment())
  d <- survey::svydesign(~dnum, weights = ~pw, data = apiclus1, fpc = ~fpc)
  d$variables$high <- d$variables$api00 > 700
  d
}

test_that("national estimate matches survey and carries precision", {
  d <- api_design()
  r <- fpa_estimate(d, "api00")
  ref <- survey::svymean(~api00, d)
  expect_equal(r$estimate, unname(coef(ref)))
  expect_equal(r$se, as.numeric(survey::SE(ref)))
  expect_equal(r$cv, 100 * r$se / r$estimate)
  expect_equal(r$ci_low, r$estimate - qnorm(0.975) * r$se)
  expect_equal(r$n, nrow(d$variables))
  expect_equal(r$quality, fpa_quality(r$cv))
})

test_that("proportions and totals by domain", {
  d <- api_design()
  p <- fpa_estimate(d, "high", type = "prop", by = "stype")
  ref <- survey::svyby(~I(as.numeric(high)), ~stype, d, survey::svymean)
  expect_equal(p$estimate, unname(coef(ref)))
  expect_true(all(p$ci_low >= 0 & p$ci_high <= 1))
  expect_equal(sum(p$n), nrow(d$variables))
  t <- fpa_estimate(d, "enroll", type = "total")
  expect_equal(t$estimate, unname(coef(survey::svytotal(~enroll, d))))
})

test_that("bad input fails with a clear class", {
  d <- api_design()
  expect_error(fpa_estimate(d$variables, "api00"), class = "fpa_error_bad_input")
  expect_error(fpa_estimate(d, "nope"), class = "fpa_error_not_found")
  expect_error(fpa_estimate(d, "api00", type = "prop"), class = "fpa_error_bad_input")
  expect_error(fpa_estimate(d, "api00", level = 2), class = "fpa_error_bad_input")
})

test_that("missing values are dropped or refused", {
  d <- api_design()
  d$variables$api00[1:3] <- NA
  expect_equal(fpa_estimate(d, "api00")$n, nrow(d$variables) - 3)
  expect_error(fpa_estimate(d, "api00", na.rm = FALSE), class = "fpa_error_missing")
})

test_that("departments get their names", {
  d <- api_design()
  d$variables$ubigeo <- ifelse(d$variables$stype == "E", "150101", "010101")
  r <- fpa_estimate(d, "api00", by = "department")
  expect_setequal(r$name, c("Lima", "Amazonas"))
})
