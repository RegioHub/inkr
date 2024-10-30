library(DBI)
library(tidyverse)

make_clean_names_de <- function(x) {
  x |>
    stringi::stri_trans_general("de-ASCII") |>
    snakecase::to_snake_case()
}

con <- dbConnect(duckdb::duckdb(), dbdir = "data-raw/inkar.duckdb")
