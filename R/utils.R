# Errors and warnings carry a class, so callers and tests can catch them by kind.
.abort <- function(kind, msg, ...) {
  msg <- if (length(list(...))) sprintf(msg, ...) else msg
  stop(structure(
    class = c(paste0("fpa_error_", kind), "fpa_error", "error", "condition"),
    list(message = msg, call = NULL)
  ))
}

.warn <- function(kind, msg, ...) {
  msg <- if (length(list(...))) sprintf(msg, ...) else msg
  warning(structure(
    class = c(paste0("fpa_warning_", kind), "fpa_warning", "warning", "condition"),
    list(message = msg, call = NULL)
  ))
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# Stata and SPSS columns come as labelled vectors; the code is what we need.
.num <- function(x) as.numeric(unclass(x))

.need <- function(pkg, why) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    .abort("missing_package", "Package '%s' is needed %s. Install it with install.packages(\"%s\").",
           pkg, why, pkg)
  }
}

# Column lookup that ignores case, since INEI files mix both.
.col <- function(data, names) {
  hit <- match(tolower(names), tolower(colnames(data)))
  hit <- hit[!is.na(hit)]
  if (length(hit)) colnames(data)[hit[1]] else NULL
}

.pad <- function(x, width) {
  x <- trimws(as.character(unclass(x)))
  x[x == ""] <- NA
  ok <- !is.na(x) & grepl("^[0-9]+$", x)
  x[ok] <- formatC(as.integer(x[ok]), width = width, flag = "0")
  x
}
