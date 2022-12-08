source(here::here("data-raw/z00-setup.R"))

dbRemoveTable(con, "inkar_raw")
dbRemoveTable(con, "inkar_values")

dbListTables(con) |>
  set_names() |>
  map(~ tbl(con, .x))

dbExecute(con, paste0("EXPORT DATABASE '", here::here("inst/db"), "' (FORMAT PARQUET)"))

dbDisconnect(con, shutdown = TRUE)

file.remove(here::here("data-raw/inkar.duckdb"))
file.remove(here::here("data-raw/inkar.duckdb.wal"))
file.remove(here::here("data-raw/inkar_2021.csv"))
file.remove(here::here("data-raw/inkar_2021.zip"))

read_lines(here::here("inst/db/schema.sql")) |>
  keep(startsWith, "CREATE TABLE") |>
  write_lines(here::here("inst/db/schema.sql"))

read_lines(here::here("inst/db/load.sql")) |>
  keep(startsWith, "COPY") |>
  str_replace("FROM '.+/db/", "FROM '$INST_PATH/db/") |>
  write_lines(here::here("inst/db/load.sql"))
