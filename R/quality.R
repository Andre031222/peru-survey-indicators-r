#' INEI quality band for a coefficient of variation
#'
#' INEI rates the precision of a survey estimate by its coefficient of
#' variation (CV): below 5% is very good, 5% to 10% good, 10% to 15%
#' acceptable, and above 15% the estimate is only a reference
#' ("referencial") and should be read with caution.
#'
#' @param cv Coefficient of variation in percent.
#' @return A character vector: `"muy buena"`, `"buena"`, `"aceptable"` or
#'   `"referencial"`, `NA` where `cv` is missing.
#' @references INEI, notes on precision of the estimates in its
#'   publications from ENAHO and ENDES (e.g. "Peru: Evolucion de los
#'   Indicadores de Empleo e Ingreso por Departamento", Lib. 1690,
#'   chap. 9).
#' @export
#' @examples
#' fpa_quality(c(3, 7.5, 12, 20))
fpa_quality <- function(cv) {
  if (!is.numeric(cv)) .abort("bad_input", "`cv` must be numeric (percent).")
  out <- as.character(cut(cv, c(-Inf, 5, 10, 15, Inf), right = FALSE,
                          labels = c("muy buena", "buena", "aceptable", "referencial")))
  out[is.nan(cv) | is.infinite(cv)] <- NA_character_
  out
}
