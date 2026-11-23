test_that("the list of indicators is complete", {
  x <- fpa_indicators()
  expect_true(all(c("pobreza_monetaria", "desempleo", "informalidad", "anemia_6_35",
                    "mujeres_productoras") %in% x$id))
  expect_true(all(grepl("https://", x$source)))
  expect_error(fpa_indicator("nope", 2024), class = "fpa_error_unknown_indicator")
  expect_error(fpa_indicator("desempleo", "2024"), class = "fpa_error_bad_input")
})

# Official INEI figures for 2024, rounded to one decimal as published.
check_official <- function(id, by = "national") {
  r <- fpa_indicator(id, 2024, by = by, cache = local_root())
  expect_equal(round(100 * r$estimate, 1), round(100 * r$official, 1), label = paste(id, by))
  r
}

test_that("ENAHO poverty matches INEI 2024", {
  skip_if_no_local()
  check_official("pobreza_monetaria")
  r <- check_official("pobreza_monetaria", by = "area")
  expect_setequal(r$domain, c("urban", "rural"))
  check_official("pobreza_extrema")
})

test_that("EPEN unemployment and informality match INEI 2024", {
  skip_if_no_local()
  check_official("desempleo")
  check_official("informalidad")
})

test_that("ENDES child anaemia matches INEI 2024 under both criteria", {
  skip_if_no_local()
  check_official("anemia_6_35")
  check_official("anemia_6_35", by = "area")
  check_official("anemia_6_35_rm363")
  check_official("anemia_6_35_rm363", by = "area")
})

test_that("ENA women producers match INEI 2024", {
  skip_if_no_local()
  r <- check_official("mujeres_productoras")
  d <- fpa_indicator("mujeres_productoras", 2024, by = "department", cache = local_root())
  expect_gte(nrow(d), 24)
  expect_true(all(is.na(d$official)))
})
