source("data-raw/z00-setup.R")

dbRemoveTable(con, "inkar_raw")

dbListTables(con) |>
  set_names() |>
  map(~ tbl(con, .x))

dbExecute(con, "EXPORT DATABASE 'inst/db' (FORMAT PARQUET)")

dbDisconnect(con, shutdown = TRUE)

unlink("data-raw/inkar.duckdb")
unlink("data-raw/inkar_2024.zip")
unlink("data-raw/inkar_2024", recursive = TRUE)

read_lines("inst/db/schema.sql") |>
  keep(startsWith, "CREATE TABLE") |>
  write_lines("inst/db/schema.sql")

read_lines("inst/db/load.sql") |>
  keep(startsWith, "COPY") |>
  str_replace("FROM '.+/db/", "FROM '$INST_PATH/db/") |>
  write_lines("inst/db/load.sql")
