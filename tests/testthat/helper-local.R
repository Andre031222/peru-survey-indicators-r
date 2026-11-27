# A local copy of the microdata (<SURVEY>/<year>/<file>.zip). The tests that
# need it run only when FAPERU_LOCAL points to one.
local_root <- function() {
  Sys.getenv("FAPERU_LOCAL", "")
}

skip_if_no_local <- function() {
  skip_on_cran()
  if (!nzchar(local_root()) || !dir.exists(local_root())) skip("Set FAPERU_LOCAL to a local microdata copy")
}
