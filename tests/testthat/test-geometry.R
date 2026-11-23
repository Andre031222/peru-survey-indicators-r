fake_layer <- function(cache, layer = "ig_departamento") {
  dir.create(file.path(cache, "GEO"), recursive = TRUE)
  sq <- function(x0, code, name) {
    sprintf(paste0('{"type":"Feature","properties":{"ccdd":"%s","nombdep":"%s"},',
                   '"geometry":{"type":"Polygon","coordinates":[[[%d,0],[%d,0],[%d,1],[%d,1],[%d,0]]]}}'),
            code, name, x0, x0 + 1, x0 + 1, x0, x0)
  }
  writeLines(paste0('{"type":"FeatureCollection","features":[', sq(0, "01", "AMAZONAS"), ",",
                    sq(1, "15", "LIMA"), "]}"),
             file.path(cache, "GEO", paste0(layer, ".geojson")))
}

test_that("cached boundaries are read without downloading", {
  skip_if_not_installed("sf")
  cache <- tempfile()
  fake_layer(cache)
  g <- fpa_geometry("department", cache = cache)
  expect_s3_class(g, "sf")
  expect_equal(g$code, c("01", "15"))
})

test_that("a failed download says so", {
  skip_if_not_installed("sf")
  local_mocked_bindings(.geo_url = function(layer) "file:///nonexistent/layer.json")
  expect_error(fpa_geometry("department", cache = tempfile()), class = "fpa_error_download")
})

test_that("the INEI geoserver answers", {
  skip_if_not_installed("sf")
  skip_if(Sys.getenv("FPA_ONLINE") != "1", "Set FPA_ONLINE=1 to download the INEI layers")
  g <- fpa_geometry("department", cache = tempfile())
  expect_equal(nrow(g), 25)
})
