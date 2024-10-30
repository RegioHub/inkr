source("data-raw/z00-setup.R")

inkar_raw_duck <- tbl(con, "inkar_raw") |>
  rename_with(make_clean_names_de)


# Indikatoren -------------------------------------------------------------

# Key: ID
# inkar_raw_duck |>
#   distinct(ID, Bereich, Indikator) |>
#   count(ID) |>
#   filter(n > 1)

indikatoren_ids <- inkar_raw_duck |>
  distinct(id, bereich) |>
  collect()

indikatoren_xlsx <- "data-raw/inkar_2024/INKAR 2024 Indikatorenübersicht.xlsx"

indikatoren_ref <-
  # Number of rows to skip in each sheet:
  c(2, 1, 2, 1) |>
  set_names(
    setdiff(readxl::excel_sheets(indikatoren_xlsx), "Nutzungshinweise"),
  ) |>
  imap(\(skip, sheet) {
    readxl::read_xlsx(
      indikatoren_xlsx,
      sheet = sheet,
      skip = skip
    ) |>
      rename_with(make_clean_names_de) |>
      drop_na(kuerzel) |>
      mutate(across(ends_with("id"), as.integer)) |>
      select(kuerzel:statistische_grundlagen)
  }) |>
  list_rbind(names_to = "rubrik")

# 12 indicators not in data
# anti_join(indikatoren_ref, indikatoren_ids, by = join_by(merk_id == id))

indikatoren <- indikatoren_ref |>
  inner_join(indikatoren_ids, by = join_by(merk_id == id)) |>
  relocate(bereich, .after = rubrik)

dbExecute(con, "
  CREATE TABLE _indikatoren(
    merk_id INTEGER PRIMARY KEY,
    m_id INTEGER,
    rubrik VARCHAR,
    bereich VARCHAR,
    kuerzel VARCHAR,
    kurzname VARCHAR,
    name VARCHAR,
    algorithmus VARCHAR,
    anmerkungen VARCHAR,
    statistische_grundlagen VARCHAR
  )
")

dbAppendTable(con, "_indikatoren", indikatoren)


# Regionen ----------------------------------------------------------------

# Key: [Raumbezug, Kennziffer]
# inkar_raw_duck |>
#   distinct(Raumbezug, Kennziffer, Name) |>
#   count(Raumbezug, Kennziffer) |>
#   filter(n > 1)

regionen <- inkar_raw_duck |>
  distinct(raumbezug, kennziffer, name) |>
  collect()

dbExecute(con, "
  CREATE TABLE _regionen(
    raumbezug VARCHAR,
    kennziffer VARCHAR,
    name VARCHAR,
    PRIMARY KEY (raumbezug, kennziffer)
  )
")

dbAppendTable(con, "_regionen", regionen)

# TODO: Add data from BBSR_Raumgliederungen_Referenzen_2022.xlsx

dbDisconnect(con, shutdown = TRUE)
