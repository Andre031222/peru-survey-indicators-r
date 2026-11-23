# INEI boundaries from the IDE INEI geoserver (WFS, GeoJSON, EPSG:4326).
.geo_layers <- c(department = "ig_departamento", district = "ig_distrito")

.geo_url <- function(layer) {
  paste0("https://geoespacial.inei.gob.pe/geoserver/Interoperabilidad/ows?service=WFS",
         "&version=1.0.0&request=GetFeature&typeName=Interoperabilidad%3A", layer,
         "&outputFormat=application%2Fjson")
}

#' INEI boundaries for maps
#'
#' Downloads the department or district boundaries published by INEI in
#' its spatial data infrastructure (IDE INEI, layers `ig_departamento`
#' and `ig_distrito`) and keeps them in the cache, so the download
#' happens once. The files are large (about 9 MB and 47 MB) and are never
#' part of the package.
#'
#' @param level `"department"` or `"district"`.
#' @param cache Cache folder; the files go to `<cache>/GEO`.
#' @param refresh Download again even if the file is cached.
#' @return An `sf` object with `code` (two-digit department code or
#'   six-digit ubigeo), `name` and the geometry.
#' @source <https://ide.inei.gob.pe/>, WFS service at
#'   `https://geoespacial.inei.gob.pe/geoserver/Interoperabilidad/ows`.
#' @export
#' @examples
#' \dontrun{
#' dep <- fpa_geometry("department")
#' }
fpa_geometry <- function(level = c("department", "district"), cache = faperu::fa_cache(),
                         refresh = FALSE) {
  level <- match.arg(level)
  .need("sf", "to read the boundaries")
  layer <- .geo_layers[[level]]
  file <- file.path(cache, "GEO", paste0(layer, ".geojson"))
  if (refresh || !file.exists(file)) .geo_download(layer, file)
  g <- sf::read_sf(file, quiet = TRUE)
  if (level == "department") {
    out <- data.frame(code = .pad(g$ccdd, 2), name = g$nombdep, stringsAsFactors = FALSE)
  } else {
    out <- data.frame(code = .pad(g$ubigeo, 6), name = g$nombdist, stringsAsFactors = FALSE)
  }
  sf::st_sf(out, geometry = sf::st_geometry(g))
}

.geo_download <- function(layer, file) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(file, ".part")
  on.exit(unlink(tmp), add = TRUE)
  old <- options(timeout = max(600, getOption("timeout")))
  on.exit(options(old), add = TRUE)
  ok <- tryCatch(utils::download.file(.geo_url(layer), tmp, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  # The geoserver answers errors as XML with status 200, so check the content too.
  head <- if (ok && file.exists(tmp)) readChar(tmp, 40, useBytes = TRUE) else ""
  if (!ok || !grepl("FeatureCollection", head, fixed = TRUE)) {
    .abort("download", "Could not download the INEI layer %s from %s.", layer, .geo_url(layer))
  }
  file.rename(tmp, file)
  invisible(file)
}
