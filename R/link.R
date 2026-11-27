#' Join estimates from several surveys
#'
#' Puts side by side estimate tables from different surveys (from
#' [fpa_estimate()] or [fpa_indicator()]) for the same departments or
#' districts. District codes are first moved to the 2017 Census frame
#' with [faperu::fa_ubigeo()], so a district created after 2017 lines up
#' with the district it came from.
#'
#' @param ... Estimate tables, named: the names become column suffixes,
#'   e.g. `fpa_link(poverty = p, women = w)`.
#' @param level `"department"` or `"district"`. Each table must have been
#'   estimated at that level.
#' @param base Census year of the district frame (2017).
#' @param by_year Join on year as well. Needs a `year` column in every
#'   table (fpa_indicator() adds it). Set to `FALSE` to cross different
#'   years on purpose.
#' @param all Keep areas that are missing in some tables (`TRUE`) or only
#'   those present in all (`FALSE`).
#' @return A data frame with the key (`department` or `ubigeo_base`), its
#'   `name`, `year` when joined by year, and for each table the columns
#'   `estimate_<name>`, `se_<name>`, `cv_<name>`, `quality_<name>` and
#'   `n_<name>` (plus `status_<name>` for districts), of class `fpa_link`
#'   (see [fpa-methods]).
#' @details Warns when a table has estimates with CV above 15%
#'   ("referencial" for INEI), when a district split from several 2017
#'   districts ("multi_parent") and cannot be placed, and when several
#'   districts fall on the same 2017 district: then the estimate of the
#'   2017 district itself is kept, because survey estimates of different
#'   areas cannot be added without their totals.
#' @export
#' @examples
#' a <- data.frame(by = "department", domain = c("01", "02"), estimate = c(.3, .4),
#'                 se = .01, cv = c(3, 2.5), n = 100, quality = "muy buena", year = 2024)
#' b <- transform(a, estimate = c(.5, .6))
#' fpa_link(poverty = a, other = b)
fpa_link <- function(..., level = c("department", "district"), base = 2017,
                     by_year = TRUE, all = FALSE) {
  tabs <- list(...)
  level <- match.arg(level)
  if (length(tabs) < 2L) .abort("bad_input", "Give at least two estimate tables.")
  nm <- names(tabs)
  if (is.null(nm) || any(nm == "") || anyDuplicated(nm)) {
    .abort("bad_input", "Name every table, e.g. fpa_link(poverty = p, women = w).")
  }
  key <- if (level == "department") "department" else "ubigeo_base"
  prepared <- Map(function(x, name) .link_one(x, name, level, base, by_year), tabs, nm)
  by <- c(key, if (by_year) "year")
  out <- Reduce(function(a, b) merge(a, b, by = by, all = all), prepared)
  if (nrow(out) == 0L) .warn("no_match", "No area is common to all tables.")
  out$name <- .area_names(out[[key]], level, base)
  out <- out[order(out[[key]]), c(by, "name", setdiff(names(out), c(by, "name"))), drop = FALSE]
  rownames(out) <- NULL
  .as(out, "fpa_link")
}

.link_one <- function(x, name, level, base, by_year) {
  need <- c("domain", "estimate", "se", "cv")
  if (!is.data.frame(x) || !all(need %in% names(x))) {
    .abort("bad_input", "Table '%s' is not an estimate table (needs %s).", name,
           paste(need, collapse = ", "))
  }
  if ("by" %in% names(x) && any(x$by != level)) {
    .abort("bad_input", "Table '%s' was estimated by %s, not by %s.", name, x$by[1], level)
  }
  if ((by_year || level == "district") && !"year" %in% names(x)) {
    .abort("bad_input", "Table '%s' needs a `year` column.", name)
  }
  quality <- x$quality %||% fpa_quality(x$cv)
  low <- sum(!is.na(x$cv) & x$cv > 15)
  if (low > 0) {
    .warn("low_precision", "Table '%s': %d of %d estimates have CV above 15%% (INEI 'referencial').",
          name, low, nrow(x))
  }
  out <- data.frame(estimate = x$estimate, se = x$se, cv = x$cv, quality = quality,
                    n = x$n %||% NA_integer_, stringsAsFactors = FALSE)
  if (level == "department") {
    key <- .pad(x$domain, 2)
    out <- cbind(data.frame(department = key, stringsAsFactors = FALSE), out)
  } else {
    out <- cbind(.to_base(x, name, base), out)
  }
  if (by_year) out$year <- as.integer(x$year)
  if (!by_year && "year" %in% names(x)) out$year_ <- x$year
  out <- out[!is.na(out[[1]]), , drop = FALSE]
  ren <- setdiff(names(out), c("department", "ubigeo_base", if (by_year) "year"))
  names(out)[match(ren, names(out))] <- paste0(sub("_$", "", ren), "_", name)
  out
}

# District codes of each year to the base frame, one row per base district.
.to_base <- function(x, name, base) {
  codes <- data.frame(u = .pad(x$domain, 6), year = as.integer(x$year), stringsAsFactors = FALSE)
  res <- do.call(rbind, lapply(split(seq_len(nrow(codes)), codes$year), function(i) {
    m <- suppressWarnings(faperu::fa_ubigeo(codes[i, , drop = FALSE], "u", codes$year[i[1]], base = base))
    data.frame(i = i, ubigeo_base = m$ubigeo_base, status = m$ubigeo_status, stringsAsFactors = FALSE)
  }))
  res <- res[order(res$i), ]
  multi <- sum(res$status %in% "multi_parent")
  if (multi > 0) {
    .warn("multi_parent", "Table '%s': %d district(s) come from several %d districts and are left out.",
          name, multi, base)
  }
  lost <- sum(is.na(res$ubigeo_base) & !res$status %in% "multi_parent")
  if (lost > 0) .warn("unmatched", "Table '%s': %d code(s) have no %d district.", name, lost, base)
  # Several codes on one base district: keep the base district's own estimate.
  rank <- ifelse(res$status %in% c("same", "recoded", "area_changed", "legacy"), 1, 2)
  dup <- duplicated(res$ubigeo_base) | duplicated(res$ubigeo_base, fromLast = TRUE)
  dup <- dup & !is.na(res$ubigeo_base)
  if (any(dup)) {
    .warn("merged_districts", "Table '%s': %d %d district(s) receive several codes; kept one estimate each.",
          name, length(unique(res$ubigeo_base[dup])), base)
    ord <- order(res$ubigeo_base, rank)
    drop <- ord[duplicated(res$ubigeo_base[ord])]
    res$ubigeo_base[drop] <- NA
  }
  data.frame(ubigeo_base = res$ubigeo_base, status = res$status, stringsAsFactors = FALSE)
}

.area_names <- function(code, level, base) {
  if (level == "department") return(unname(.department_names()[code]))
  d <- faperu::fa_districts(base)
  d$distrito[match(code, d$ubigeo)]
}
