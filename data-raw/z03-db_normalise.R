source("data-raw/z00-setup.R")

inkar_raw_duck <- tbl(con, "inkar_raw") |>
  rename_with(make_clean_names_de)

# The idea is to split the data into one table per Bereich and
# use the newly available Kürzel as column names.
# Kürzel are distinct per Bereich, except for some rows in "Zentrale Orte
# Monitoring" where Kürzel is missing:
# inkar_raw_duck |>
#   count(bereich, kuerzel, raumbezug, kennziffer, zeitbezug) |>
#   filter(n > 1)
# Otherwise, no discrepancy between data and ref table:
# inkar_raw_duck |>
#   anti_join(x = tbl(con, "_indikatoren"), by = join_by(kuerzel)) |>
#   distinct(bereich, kuerzel)

# Join to fill in missing Kürzel
dbExecute(con, "
  UPDATE inkar_raw
  SET Kuerzel = _indikatoren.kuerzel
  FROM _indikatoren
  WHERE inkar_raw.id = _indikatoren.merk_id
    AND inkar_raw.Kuerzel = 'NA';
")

bereiche <- inkar_raw_duck |>
  distinct(bereich) |>
  pull()

walk(bereiche, \(bereich) {
  tbl_subset <- inkar_raw_duck |>
    filter(bereich == !!bereich) |>
    select(-bereich)

  bereich_tidy_query <- tbl_subset |>
    select(kuerzel, raumbezug, kennziffer, name, zeitbezug, wert) |>
    pivot_wider(names_from = kuerzel, values_from = wert) |>
    arrange(raumbezug, kennziffer, zeitbezug) |>
    dbplyr::remote_query()

  tbl_name <- make_clean_names_de(bereich)

  dbExecute(con, glue::glue("CREATE TABLE {tbl_name} AS {bereich_tidy_query}"))

  message("Finished writing table ", tbl_name)
})

dbDisconnect(con, shutdown = TRUE)
