#' faperu.analysis: estimation and linkage on top of faperu
#'
#' `faperu` gets the INEI microdata and the survey design; this package
#' turns them into numbers for a paper:
#'
#' - [fpa_estimate()]: means, proportions and totals by domain, with
#'   standard error, confidence interval, coefficient of variation and
#'   the INEI quality band ([fpa_quality()]).
#' - [fpa_indicator()]: ready indicators (poverty, unemployment,
#'   informality, child anaemia, women producers), checked against the
#'   figures INEI published. [fpa_indicators()] lists them.
#' - [fpa_link()]: joins estimates from different surveys by district or
#'   department and year, on the 2017 Census district frame.
#' - [fpa_map()] and [fpa_geometry()]: choropleth maps with the INEI
#'   boundaries, downloaded once to the cache.
#' - [fpa_table()]: a table ready for a paper.
#'
#' @keywords internal
"_PACKAGE"
