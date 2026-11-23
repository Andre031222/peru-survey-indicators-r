utils::globalVariables("fpa_fill")

#' Choropleth map of estimates
#'
#' Draws estimates by department or district on the INEI boundaries
#' ([fpa_geometry()]). Areas without an estimate are drawn in grey.
#'
#' @param x A table with one row per area, e.g. from [fpa_estimate()],
#'   [fpa_indicator()] or [fpa_link()].
#' @param value Column to map.
#' @param level `"department"` or `"district"`.
#' @param key Column with the area code. By default `department`,
#'   `ubigeo_base`, `ubigeo` or `domain`, the first one found.
#' @param base With `level = "district"`, the census year of the codes in
#'   `x` (e.g. 2017 after [fpa_link()]). The district boundaries are then
#'   merged into the districts of that year; districts that split from
#'   several of them stay grey.
#' @param percent Show the legend in percent.
#' @param title Map title.
#' @param geometry Boundaries to use instead of downloading them, an `sf`
#'   object with `code` and `name` as returned by [fpa_geometry()].
#' @param cache Cache folder for the boundaries.
#' @return A `ggplot` object.
#' @export
#' @examples
#' \dontrun{
#' p <- fpa_indicator("pobreza_monetaria", 2024, by = "department")
#' fpa_map(p, title = "Monetary poverty 2024")
#' }
fpa_map <- function(x, value = "estimate", level = c("department", "district"), key = NULL,
                    base = NULL, percent = TRUE, title = NULL, geometry = NULL,
                    cache = faperu::fa_cache()) {
  level <- match.arg(level)
  .need("sf", "for maps")
  .need("ggplot2", "for maps")
  if (!is.data.frame(x)) .abort("bad_input", "`x` must be a data frame.")
  if (!value %in% names(x)) .abort("not_found", "Column `%s` not found.", value)
  if (!is.numeric(x[[value]])) .abort("bad_input", "Column `%s` must be numeric.", value)
  key <- key %||% intersect(c("department", "ubigeo_base", "ubigeo", "domain"), names(x))[1]
  if (is.na(key) || !key %in% names(x)) .abort("not_found", "No column with the area code; set `key`.")
  code <- .pad(x[[key]], if (level == "department") 2 else 6)
  if (anyDuplicated(code[!is.na(code)])) .abort("bad_input", "Several rows per area in `x`.")

  g <- geometry %||% fpa_geometry(level, cache = cache)
  if (!inherits(g, "sf") || !all(c("code", "name") %in% names(g))) {
    .abort("bad_input", "`geometry` must be an sf object with `code` and `name`.")
  }
  if (level == "district" && !is.null(base)) g <- .dissolve(g, base)
  g$fpa_fill <- x[[value]][match(g$code, code)]
  missing <- setdiff(code[!is.na(code)], g$code)
  if (length(missing)) {
    .warn("not_on_map", "%d area(s) of `x` are not on the map: %s.", length(missing),
          paste(utils::head(missing, 5), collapse = ", "))
  }
  labels <- if (percent) function(v) paste0(format(100 * v, trim = TRUE), "%") else ggplot2::waiver()
  ggplot2::ggplot(g) +
    ggplot2::geom_sf(ggplot2::aes(fill = fpa_fill), colour = "white",
                     linewidth = if (level == "department") 0.2 else 0.05) +
    ggplot2::scale_fill_viridis_c(option = "magma", direction = -1, na.value = "grey85",
                                  labels = labels, name = NULL) +
    ggplot2::labs(title = title) +
    ggplot2::theme_void()
}

# Current district boundaries merged into the districts of the base census.
.dissolve <- function(g, base) {
  m <- suppressWarnings(faperu::fa_ubigeo(data.frame(u = g$code), "u", as.integer(format(Sys.Date(), "%Y")),
                                          base = base))
  g$base <- ifelse(is.na(m$ubigeo_base), g$code, m$ubigeo_base)
  g$base[m$ubigeo_status %in% "multi_parent"] <- NA
  several <- unique(g$base[duplicated(g$base) & !is.na(g$base)])
  if (length(several) == 0L) {
    g$code <- g$base
    return(g[, c("code", "name")])
  }
  one <- g[!g$base %in% several, ]
  one$code <- one$base
  merged <- lapply(several, function(b) {
    part <- g[g$base %in% b, ]
    keep <- part[part$code == b, ]
    sf::st_sf(code = b, name = if (nrow(keep)) keep$name[1] else part$name[1],
              geometry = sf::st_union(sf::st_make_valid(sf::st_geometry(part))))
  })
  rbind(one[, c("code", "name")], do.call(rbind, merged))
}
