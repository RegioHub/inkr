library(callr)

rscript("data-raw/z01-db_import_raw.R")
rscript("data-raw/z02-db_meta.R")
rscript("data-raw/z03-db_normalise.R")
rscript("data-raw/z04-db_export.R")

inkar <- structure(
  list(),
  class = "inkar_db"
)

usethis::use_data(inkar, overwrite = TRUE)
