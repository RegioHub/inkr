library(callr)

rscript(here::here("data-raw/z01-db_import_raw.R"))
rscript(here::here("data-raw/z02-db_meta.R"))
rscript(here::here("data-raw/z03-db_normalise.R"))
rscript(here::here("data-raw/z04-db_export.R"))

inkar <- structure(
  list(),
  class = "inkar_db"
)

usethis::use_data(inkar, overwrite = TRUE)
