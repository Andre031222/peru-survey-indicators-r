api_estimate <- function() {
  data(api, package = "survey", envir = environment())
  d <- survey::svydesign(~dnum, weights = ~pw, data = apiclus1, fpc = ~fpc)
  d$variables$high <- d$variables$api00 > 700
  fpa_estimate(d, "high", type = "prop", by = "stype")
}

test_that("estimates print as a formatted table and stay data frames", {
  e <- api_estimate()
  expect_s3_class(e, c("fpa_estimate", "data.frame"))
  out <- capture.output(print(e))
  expect_match(out[1], "<fpa estimate: prop of `high` by stype, 3 rows>", fixed = TRUE)
  expect_true(any(grepl("^ E +", out)))
  expect_true(any(grepl("referencial", out)))
  expect_identical(class(as.data.frame(e)), "data.frame")
  expect_no_error(capture.output(print(e[, c("domain", "n")])))
})

test_that("summary counts estimates by INEI quality band", {
  s <- summary(api_estimate())
  expect_identical(s$quality, c("muy buena", "buena", "aceptable", "referencial"))
  expect_identical(sum(s$n), 3L)
  expect_equal(sum(s$share), 1)
})

test_that("plot draws without error and returns the table", {
  e <- api_estimate()
  f <- tempfile(fileext = ".png")
  grDevices::png(f)
  on.exit({ grDevices::dev.off(); unlink(f) })
  expect_identical(plot(e), e)
})

test_that("linked tables print with a header", {
  a <- data.frame(by = "department", domain = c("01", "02"), estimate = c(.3, .4),
                  se = .01, cv = c(3, 2.5), n = 100, quality = "muy buena", year = 2024)
  l <- fpa_link(poverty = a, other = transform(a, estimate = c(.5, .6)))
  expect_s3_class(l, "fpa_link")
  expect_match(capture.output(print(l))[1], "poverty + other by department, 2 areas", fixed = TRUE)
})
