source(here::here("data-raw/z00-setup.R"))

inkar_raw_duck <- tbl(con, "inkar_raw")


# Remove columns from raw table -------------------------------------------

regionen_duck <- tbl(con, "_regionen")

inkar_values_query <- inkar_raw_duck |>
  rename_with(make_clean_names_de) |>
  mutate(
    kennziffer = as.character(kennziffer),
    kennziffer = coalesce(kennziffer, kennziffer_eu)
  ) |>
  select(indikator_id = id, bereich, raumbezug, kennziffer, zeitbezug, wert) |>
  left_join(
    regionen_duck |>
      mutate(
        kennziffer = as.character(kennziffer),
        kennziffer = coalesce(kennziffer, kennziffer_eu)
      ),
    by = c("raumbezug", "kennziffer")
  ) |>
  select(-c(raumbezug, kennziffer, kennziffer_eu, name)) |>
  rename(region_id = id) |>
  relocate(region_id) |>
  dbplyr::remote_query()

dbExecute(con, paste0("CREATE TABLE inkar_values AS ", inkar_values_query))

inkar_values_duck <- tbl(con, "inkar_values")


# Split value table by Bereich --------------------------------------------

# TODO: Foreign key on region_id when supported https://github.com/duckdb/duckdb/issues/46

bereiche <- inkar_values_duck |>
  distinct(bereich) |>
  pull() |>
  setdiff(dbListTables(con))

walk(bereiche, function(bereich) {
  tbl_subset <- inkar_values_duck |>
    filter(bereich == !!bereich) |>
    select(-bereich)

  varnames <- tbl_subset |>
    distinct(indikator_id) |>
    pull() |>
    sort() |>
    . => paste0("x", .)

  bereich_tidy_query <- tbl_subset |>
    pivot_wider(names_from = indikator_id, names_prefix = "x", values_from = "wert") |>
    relocate(all_of(varnames), .after = last_col()) |>
    arrange(region_id, zeitbezug) |>
    dbplyr::remote_query()

  tbl_name <- make_clean_names_de(bereich)

  dbExecute(con, glue::glue("CREATE TABLE {tbl_name} AS {bereich_tidy_query}"))

  message("Finished writing table ", tbl_name)
})

dbDisconnect(con, shutdown = TRUE)
