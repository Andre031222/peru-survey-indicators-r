# How each ready indicator is built from the INEI files. Every recipe takes
# the year and the cache and returns the design plus the 0/1 variable.

.recipe_enaho_poverty <- function(year, cache, extreme = FALSE) {
  s <- faperu::fa_read("enaho", year, "34", file = sprintf("Sumaria-%d\\.", year),
                       series = "anual", cache = cache)
  s <- as.data.frame(s)
  # Poverty is a share of people, so the household weight goes times household size.
  s$fpa_w <- .num(s$factor07) * .num(s$mieperho)
  pov <- .num(s$pobreza)
  s$fpa_y <- if (extreme) as.numeric(pov == 1) else as.numeric(pov %in% 1:2)
  # ENAHO strata 1 to 5 are urban, 6 to 8 rural.
  s$area <- ifelse(.num(s$estrato) <= 5, 1, 2)
  .design(s, "enaho", weight = "fpa_w")
}

.recipe_epen <- function(year, cache, what) {
  cat <- faperu::fa_catalog("epen", year)
  hit <- cat[cat$series == "departamentos" & grepl("^Anual", cat$period), , drop = FALSE]
  if (nrow(hit) != 1L) .abort("not_available", "No annual EPEN department file for %d.", year)
  e <- faperu::fa_read("epen", year, hit$module, series = "departamentos",
                       period = "^Anual", cache = cache)
  e <- as.data.frame(e)
  ocup <- .num(e$ocup300)
  if (what == "unemployment") {
    # Open unemployment over the labour force (employed 1, unemployed 2).
    e <- e[ocup %in% 1:2, , drop = FALSE]
    e$fpa_y <- as.numeric(.num(e$ocup300) == 2)
  } else {
    e <- e[ocup %in% 1 & !is.na(e$informal_p), , drop = FALSE]
    e$fpa_y <- as.numeric(.num(e$informal_p) == 1)
  }
  .design(e, "epen")
}

.recipe_endes_anaemia <- function(year, cache, criterion) {
  read <- function(module, file) {
    x <- faperu::fa_read("endes", year, module, file = file, cache = cache)
    x <- as.data.frame(lapply(x, function(v) if (is.character(v)) v else .num(v)),
                       stringsAsFactors = FALSE)
    x
  }
  r6 <- read("1638", "^RECH6")
  r0 <- read("1629", "^RECH0")
  r1 <- read("1629", "^RECH1")
  var <- if (criterion == "who2024") "hc57a" else "hc57"
  if (!var %in% names(r6)) .abort("not_available", "ENDES %d has no %s.", year, toupper(var))
  r1$hc0 <- r1$hvidx
  keep0 <- intersect(c("hhid", "hv001", "hv005", "hv022", "hv024", "hv025", "ubigeo"), names(r0))
  m <- merge(r6, r0[, keep0], by = "hhid")
  m <- merge(m, r1[, c("hhid", "hc0", "hv103")], by = c("hhid", "hc0"), all.x = TRUE)
  # Children 6 to 35 months who slept in the house the night before, with a valid test.
  m <- m[m$hc1 >= 6 & m$hc1 <= 35 & m$hv103 %in% 1 & m[[var]] %in% 1:4, , drop = FALSE]
  m$fpa_y <- as.numeric(m[[var]] %in% 1:3)
  .design(m, "endes")
}

.recipe_ena_women <- function(year, cache) {
  a <- as.data.frame(faperu::fa_read("ena", year, "1911", cache = cache))
  est <- trimws(as.character(unclass(a$estrato)))
  # Producers who answered (P1102 == 1), in the area frame (with a stratum).
  a <- a[.num(a$p1102) %in% 1 & !is.na(est) & est != "", , drop = FALSE]
  a <- a[!is.na(a$p1103), , drop = FALSE]
  a$fpa_y <- as.numeric(.num(a$p1103) == 2)
  .design(a, "ena")
}

.design <- function(data, survey, ...) {
  if (nrow(data) == 0L) .abort("empty", "No cases left for the indicator.")
  # fpa_estimate() handles strata with a single cluster, so that warning is noise here.
  withCallingHandlers(
    suppressMessages(faperu::fa_design(data, survey, ...)),
    faperu_warning_design = function(w) {
      if (grepl("single cluster", conditionMessage(w))) invokeRestart("muffleWarning")
    }
  )
}
