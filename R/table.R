#' Table of estimates for a paper
#'
#' Formats an estimate table ([fpa_estimate()] or [fpa_indicator()]) the
#' way it goes in a paper: one row per area with the estimate, its
#' confidence interval, the CV and the number of cases. Estimates with CV
#' above 15% (INEI "referencial") are marked with an asterisk and a note.
#'
#' @param x An estimate table.
#' @param digits Decimals for the estimate and the interval.
#' @param percent Show proportions in percent.
#' @param format `"data.frame"`, `"markdown"` or `"latex"`.
#' @param caption Caption for markdown and LaTeX.
#' @return A data frame, or a character vector with the lines of the
#'   table (print it with `cat(..., sep = "\\n")`).
#' @export
#' @examples
#' x <- data.frame(name = c("Lima", "Ica"), estimate = c(.27, .06), se = c(.012, .009),
#'                 ci_low = c(.246, .042), ci_high = c(.294, .078), cv = c(4.5, 15.6),
#'                 n = c(5000, 900))
#' fpa_table(x)
#' cat(fpa_table(x, format = "markdown"), sep = "\n")
fpa_table <- function(x, digits = 1, percent = TRUE, format = c("data.frame", "markdown", "latex"),
                      caption = NULL) {
  format <- match.arg(format)
  need <- c("estimate", "ci_low", "ci_high", "cv")
  if (!is.data.frame(x) || !all(need %in% names(x))) {
    .abort("bad_input", "`x` must be an estimate table with %s.", paste(need, collapse = ", "))
  }
  k <- if (percent) 100 else 1
  f <- function(v) formatC(k * v, format = "f", digits = digits, big.mark = ",")
  low <- x$cv > 15 & !is.na(x$cv)
  area <- x$name %||% x$domain %||% seq_len(nrow(x))
  out <- data.frame(
    Area = as.character(area),
    Estimate = paste0(f(x$estimate), ifelse(low, "*", "")),
    `95% CI` = paste0(f(x$ci_low), " - ", f(x$ci_high)),
    `CV (%)` = formatC(x$cv, format = "f", digits = 1),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  lvl <- attr(x, "level")
  if (!is.null(lvl) && lvl != 0.95) names(out)[3] <- sprintf("%g%% CI", 100 * lvl)
  if ("n" %in% names(x)) out$n <- formatC(x$n, format = "d", big.mark = ",")
  if ("official" %in% names(x) && any(!is.na(x$official))) {
    out$INEI <- ifelse(is.na(x$official), "", f(x$official))
  }
  note <- if (any(low)) "* CV above 15%: INEI rates the estimate as a reference only (referencial)." else NULL
  if (format == "data.frame") {
    attr(out, "note") <- note
    return(out)
  }
  if (format == "markdown") {
    lines <- c(if (!is.null(caption)) c(paste0("Table: ", caption), ""),
               paste0("| ", paste(names(out), collapse = " | "), " |"),
               paste0("|", paste(c(":--", rep("--:", ncol(out) - 1)), collapse = "|"), "|"),
               apply(out, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")),
               if (!is.null(note)) c("", note))
    return(lines)
  }
  esc <- function(s) gsub("([%&_#$])", "\\\\\\1", s)
  c("\\begin{table}[ht]", "\\centering",
    if (!is.null(caption)) paste0("\\caption{", esc(caption), "}"),
    paste0("\\begin{tabular}{l", strrep("r", ncol(out) - 1), "}"), "\\hline",
    paste0(paste(esc(names(out)), collapse = " & "), " \\\\"), "\\hline",
    apply(out, 1, function(r) paste0(paste(esc(r), collapse = " & "), " \\\\")),
    "\\hline", "\\end{tabular}",
    if (!is.null(note)) paste0("\\par\\footnotesize ", esc(note)),
    "\\end{table}")
}
