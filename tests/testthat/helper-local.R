local_root <- function() {
  Sys.getenv("FAPERU_LOCAL", "/mnt/discoD/Research-Dev/AUP_Papers/datos/inei_microdatos")
}

skip_if_no_local <- function() {
  skip_on_cran()
  if (!dir.exists(local_root())) skip("Local INEI microdata not found (set FAPERU_LOCAL)")
}
