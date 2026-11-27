# Print, summary and plot for estimate tables. They stay data frames; the
# class only changes how they look. A table that lost the columns a method
# needs prints as a plain data frame.

.as <- function(x, cls) {
  class(x) <- unique(c(cls, class(x)))
  x
}

.plain <- function(x) {
  class(x) <- setdiff(class(x), c("fpa_estimate", "fpa_link"))
  x
}

.is_estimate <- function(x) all(c("estimate", "ci_low", "ci_high", "cv") %in% names(x))

#' Print, summarise and plot estimate tables
#'
#' [fpa_estimate()] and [fpa_indicator()] return data frames of class
#' `fpa_estimate`, and [fpa_link()] one of class `fpa_link`. They print as a
#' formatted table (the one [fpa_table()] builds), `summary()` counts the
#' estimates in each INEI quality band, and `plot()` draws each estimate
#' with its confidence interval, coloured by quality. They are still data
#' frames; [as.data.frame()] drops the class.
#'
#' @param x,object A table from [fpa_estimate()], [fpa_indicator()] or
#'   [fpa_link()].
#' @param n Rows to show.
#' @param percent Show proportions as percentages.
#' @param main Plot title; by default the variable or indicator.
#' @param ... Passed on to [print.data.frame()] or [graphics::plot()].
#' @return `print()` and `plot()` return `x` invisibly. `summary()` returns a
#'   data frame with one row per quality band: `quality`, `n` and the share
#'   of estimates.
#' @examples
#' library(survey)
#' data(api, package = "survey")
#' d <- svydesign(~dnum, weights = ~pw, data = apiclus1, fpc = ~fpc)
#' d$variables$high <- d$variables$api00 > 700
#' e <- fpa_estimate(d, "high", type = "prop", by = "stype")
#' e
#' summary(e)
#' plot(e)
#' @name fpa-methods
NULL

.what <- function(x) {
  if ("indicator" %in% names(x)) {
    sprintf("%s, %s %s", x$indicator[1], toupper(x$survey[1]), x$year[1])
  } else {
    sprintf("%s of `%s`", x$type[1] %||% "estimate", x$var[1] %||% "?")
  }
}

#' @rdname fpa-methods
#' @export
print.fpa_estimate <- function(x, n = 30L, percent = NULL, ...) {
  if (!.is_estimate(x)) return(NextMethod())
  percent <- percent %||% identical(x$type[1], "prop")
  by <- x$by[1] %||% "domain"
  cat(sprintf("<fpa estimate: %s by %s, %d row%s>\n", .what(x), by, nrow(x),
              if (nrow(x) == 1L) "" else "s"))
  if (nrow(x) == 0L) return(invisible(x))
  tab <- fpa_table(.plain(x)[seq_len(min(n, nrow(x))), , drop = FALSE], percent = percent)
  tab$Quality <- x$quality[seq_len(nrow(tab))] %||% fpa_quality(x$cv[seq_len(nrow(tab))])
  print(tab, row.names = FALSE, right = FALSE, ...)
  if (nrow(x) > n) cat(sprintf("# ... %d more rows\n", nrow(x) - n))
  if (!is.null(attr(tab, "note"))) cat(attr(tab, "note"), "\n")
  invisible(x)
}

#' @rdname fpa-methods
#' @export
summary.fpa_estimate <- function(object, ...) {
  if (!.is_estimate(object)) return(summary(.plain(object), ...))
  q <- object$quality %||% fpa_quality(object$cv)
  bands <- c("muy buena", "buena", "aceptable", "referencial")
  q <- factor(q, levels = union(bands, unique(stats::na.omit(q))))
  n <- as.integer(table(q, useNA = "no"))
  out <- data.frame(quality = levels(q), n = n, share = n / max(1L, sum(n)),
                    stringsAsFactors = FALSE)
  attr(out, "cv_median") <- stats::median(object$cv, na.rm = TRUE)
  out
}

#' @rdname fpa-methods
#' @export
plot.fpa_estimate <- function(x, percent = NULL, main = NULL, ...) {
  if (!.is_estimate(x)) .abort("bad_input", "`x` is not an estimate table.")
  percent <- percent %||% identical(x$type[1], "prop")
  k <- if (percent) 100 else 1
  o <- order(x$estimate)
  lab <- as.character((x$name %||% x$domain %||% seq_len(nrow(x)))[o])
  est <- k * x$estimate[o]
  low <- k * x$ci_low[o]
  high <- k * x$ci_high[o]
  q <- (x$quality %||% fpa_quality(x$cv))[o]
  pal <- c("muy buena" = "#1F4E79", "buena" = "#4F81B4", "aceptable" = "#D08C2E",
           "referencial" = "#B23A2E")
  col <- unname(pal[q])
  col[is.na(col)] <- "grey50"
  y <- seq_along(est)

  old <- graphics::par(mar = c(4.5, max(4, 0.55 * max(nchar(lab), 1)), 3, 1), las = 1)
  on.exit(graphics::par(old), add = TRUE)
  graphics::plot(est, y, xlim = range(c(low, high), na.rm = TRUE), ylim = c(0.5, length(y) + 0.5),
                 yaxt = "n", pch = 19, col = col, xlab = if (percent) "%" else "Estimate", ylab = "",
                 main = main %||% .what(x), ...)
  graphics::segments(low, y, high, y, col = col, lwd = 2)
  graphics::axis(2, at = y, labels = lab, tick = FALSE, cex.axis = 0.8)
  if ("official" %in% names(x) && any(!is.na(x$official))) {
    graphics::points(k * x$official[o], y, pch = 4, cex = 1.1)
  }
  shown <- intersect(names(pal), q)
  if (length(shown)) {
    graphics::legend("bottomright", legend = shown, col = pal[shown], pch = 19, bty = "n",
                     cex = 0.8, title = "INEI quality")
  }
  invisible(x)
}

#' @rdname fpa-methods
#' @export
print.fpa_link <- function(x, n = 30L, ...) {
  key <- intersect(c("department", "ubigeo_base"), names(x))
  tabs <- sub("^estimate_", "", grep("^estimate_", names(x), value = TRUE))
  if (length(key) == 0L || length(tabs) == 0L) return(NextMethod())
  cat(sprintf("<fpa link: %s by %s, %d area%s>\n", paste(tabs, collapse = " + "),
              if (key == "department") "department" else "district (2017 frame)",
              nrow(x), if (nrow(x) == 1L) "" else "s"))
  print(.plain(x)[seq_len(min(n, nrow(x))), , drop = FALSE], row.names = FALSE, ...)
  if (nrow(x) > n) cat(sprintf("# ... %d more rows\n", nrow(x) - n))
  invisible(x)
}
