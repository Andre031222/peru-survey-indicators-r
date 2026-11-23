# Builds the domain column for fpa_estimate() from the design variables.
# Departments and districts come from a district code (ubigeo) or from the
# ccdd/ccpp/ccdi columns; area from `area` (1 urban, 2 rural) or ENDES hv025.
.domain <- function(data, by) {
  n <- nrow(data)
  if (by == "national") return(rep("PE", n))
  if (by %in% c("department", "district")) {
    ub <- .ubigeo(data)
    if (is.null(ub)) {
      if (by == "department" && !is.null(dd <- .col(data, "ccdd"))) return(.pad(data[[dd]], 2))
      .abort("no_domain", "No district code in the data: need a `ubigeo` column or ccdd, ccpp and ccdi.")
    }
    return(if (by == "department") substr(ub, 1, 2) else ub)
  }
  if (by == "area") {
    a <- .col(data, c("area", "hv025"))
    if (is.null(a)) {
      .abort("no_domain", "No area column: add `area` with 1 = urban and 2 = rural.")
    }
    v <- data[[a]]
    if (is.character(v) && !all(grepl("^[0-9]*$", v[!is.na(v)]))) return(tolower(v))
    v <- .num(v)
    return(c("urban", "rural")[match(v, 1:2)])
  }
  col <- .col(data, by)
  if (is.null(col)) .abort("no_domain", "Column `%s` not found in the design.", by)
  as.character(unclass(data[[col]]))
}

.ubigeo <- function(data) {
  u <- .col(data, "ubigeo")
  if (!is.null(u)) return(.pad(data[[u]], 6))
  parts <- vapply(c("ccdd", "ccpp", "ccdi"), function(p) .col(data, p) %||% NA_character_, "")
  if (anyNA(parts)) return(NULL)
  paste0(.pad(data[[parts[1]]], 2), .pad(data[[parts[2]]], 2), .pad(data[[parts[3]]], 2))
}

# Department names, from the faperu district list.
.department_names <- function() {
  d <- faperu::fa_districts(2017)
  x <- unique(data.frame(code = substr(d$ubigeo, 1, 2), name = d$departamento))
  stats::setNames(x$name, x$code)[!duplicated(x$code)]
}
