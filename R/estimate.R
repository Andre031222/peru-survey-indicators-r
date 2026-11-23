#' Design-based estimate with precision
#'
#' Estimates a mean, a proportion or a total from a survey design (for
#' example one built with [faperu::fa_design()]), overall or by domain,
#' and adds the standard error, a confidence interval, the coefficient of
#' variation and the INEI quality band ([fpa_quality()]).
#'
#' @param design A `survey.design` object.
#' @param var Name of the variable to estimate. For `type = "prop"` it must
#'   be logical or coded 0/1.
#' @param type `"mean"`, `"prop"` (a mean of a 0/1 variable, kept between
#'   0 and 1) or `"total"`.
#' @param by Domain: `"national"`, `"department"`, `"area"`, `"district"`,
#'   or the name of any column in the design. Departments and districts
#'   are read from a `ubigeo` column or from `ccdd`, `ccpp` and `ccdi`;
#'   area from an `area` column (1 urban, 2 rural) or ENDES `hv025`.
#' @param level Confidence level.
#' @param na.rm Drop missing values of `var`.
#' @return A data frame with one row per domain: `by`, `domain`, `name`
#'   (department name when `by = "department"`), `var`, `type`,
#'   `estimate`, `se`, `ci_low`, `ci_high`, `cv` (percent), `n`
#'   (unweighted cases) and `quality`.
#' @details Intervals are normal (Wald) intervals; for proportions they
#'   are cut at 0 and 1. If the option `survey.lonely.psu` is left at its
#'   default (`"fail"`), strata with a single primary unit are handled with
#'   `"adjust"` during the call.
#' @export
#' @examples
#' library(survey)
#' data(api, package = "survey")
#' d <- svydesign(~dnum, weights = ~pw, data = apiclus1, fpc = ~fpc)
#' d$variables$high <- d$variables$api00 > 700
#' fpa_estimate(d, "high", type = "prop", by = "stype")
fpa_estimate <- function(design, var, type = c("mean", "prop", "total"),
                         by = "national", level = 0.95, na.rm = TRUE) {
  if (!inherits(design, "survey.design") && !inherits(design, "svyrep.design")) {
    .abort("bad_input", "`design` must be a survey design, e.g. from faperu::fa_design().")
  }
  type <- match.arg(type)
  if (!is.character(var) || length(var) != 1L) .abort("bad_input", "`var` must be one column name.")
  if (!is.character(by) || length(by) != 1L) .abort("bad_input", "`by` must be one domain name.")
  if (!is.numeric(level) || level <= 0 || level >= 1) .abort("bad_input", "`level` must be between 0 and 1.")
  data <- design$variables
  col <- .col(data, var)
  if (is.null(col)) .abort("not_found", "Variable `%s` not found in the design.", var)
  y <- data[[col]]
  if (is.logical(y)) y <- as.numeric(y)
  if (!is.numeric(y)) y <- .num(y)
  if (type == "prop" && any(!y %in% c(0, 1, NA))) {
    .abort("bad_input", "`%s` must be logical or 0/1 for a proportion.", var)
  }
  if (!na.rm && anyNA(y)) .abort("missing", "`%s` has missing values; use na.rm = TRUE.", var)

  if (identical(getOption("survey.lonely.psu", "fail"), "fail")) {
    old <- options(survey.lonely.psu = "adjust")
    on.exit(options(old), add = TRUE)
  }
  dom_all <- .domain(data, by)
  design$variables$.fpa_y <- y
  design$variables$.fpa_dom <- dom_all
  # Subsetting a design keeps the full sample for the variance, as domains should.
  keep <- !is.na(dom_all) & (!na.rm | !is.na(y))
  if (!any(keep)) .abort("empty", "No cases left to estimate `%s`.", var)
  if (!all(keep)) design <- design[keep, ]

  fun <- if (type == "total") survey::svytotal else survey::svymean
  est <- survey::svyby(~.fpa_y, ~.fpa_dom, design, fun, keep.var = TRUE, na.rm = na.rm)
  dom <- as.character(est$.fpa_dom)
  value <- unname(stats::coef(est))
  se <- unname(survey::SE(est))
  z <- stats::qnorm(1 - (1 - level) / 2)
  low <- value - z * se
  high <- value + z * se
  if (type == "prop") {
    low <- pmax(low, 0)
    high <- pmin(high, 1)
  }
  cv <- ifelse(value == 0, NA_real_, 100 * se / abs(value))
  n <- as.integer(table(factor(dom_all[keep], levels = dom)))

  name <- if (by == "department") unname(.department_names()[dom]) else
    if (by == "national") rep("Peru", length(dom)) else dom
  out <- data.frame(by = by, domain = dom, name = name, var = var, type = type,
                    estimate = value, se = se, ci_low = low, ci_high = high,
                    cv = cv, n = n, quality = fpa_quality(cv), stringsAsFactors = FALSE)
  rownames(out) <- NULL
  attr(out, "level") <- level
  out
}
