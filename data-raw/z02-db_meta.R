source(here::here("data-raw/z00-setup.R"))

inkar_raw_duck <- tbl(con, "inkar_raw")


# Indikatoren -------------------------------------------------------------

# Key: ID
# inkar_raw_duck |>
#   distinct(ID, Bereich, Indikator) |>
#   count(ID) |>
#   filter(n > 1)

indikatoren <- inkar_raw_duck |>
  distinct(ID, Bereich) |>
  arrange(ID) |>
  collect() |>
  rename_with(make_clean_names_de)

indikatoren_xlsx <-
  remote_to_local("https://www.inkar.de/documents/Uebersicht%20der%20Indikatoren.xlsx")

indikatoren_ref <- map_dfr(
  seq_along(readxl::excel_sheets(indikatoren_xlsx)),
  function(sheet) {
    readxl::read_xlsx(
      indikatoren_xlsx,
      sheet = sheet,
      skip = if (sheet <= 2) 2 else 1
    ) |>
      mutate(ID = as.integer(ID)) |>
      drop_na(ID) |>
      select(ID:`Statistische Grundlagen`) |>
      rename_with(make_clean_names_de)
  }
)

# anti_join(indikatoren_ref, indikatoren)
# 531 not in data

indikatoren <- indikatoren |>
  left_join(indikatoren_ref, by = "id")

dbExecute(con, "
  CREATE TABLE _indikatoren(
    id INTEGER PRIMARY KEY,
    bereich VARCHAR,
    kurzname VARCHAR,
    name VARCHAR,
    algorithmus VARCHAR,
    anmerkungen VARCHAR,
    statistische_grundlagen VARCHAR
  )
")

dbAppendTable(con, "_indikatoren", indikatoren)


# Regionen ----------------------------------------------------------------

# Key: [Raumbezug, Kennziffer] if Bereich != "Europa" else [Raumbezug, Kennziffer_EU]
# inkar_raw_duck |>
#   mutate(
#     Kennziffer = as.character(Kennziffer),
#     Kennziffer = coalesce(Kennziffer, Kennziffer_EU)
#   ) |>
#   distinct(Raumbezug, Kennziffer, Name) |>
#   count(Raumbezug, Kennziffer) |>
#   filter(n > 1)

regionen <- inkar_raw_duck |>
  distinct(Raumbezug, Kennziffer, Kennziffer_EU, Name) |>
  mutate(id = as.integer(row_number())) |>
  collect() |>
  rename_with(make_clean_names_de)

dbExecute(con, "
  CREATE TABLE _regionen(
    id INTEGER PRIMARY KEY,
    raumbezug VARCHAR,
    kennziffer INTEGER,
    kennziffer_eu VARCHAR,
    name VARCHAR
  )
")

dbAppendTable(con, "_regionen", regionen)

# TODO: Add data from https://www.inkar.de/documents/Referenz%20Gemeinden,%20Kreise,%20NUTS.xlsx

dbDisconnect(con, shutdown = TRUE)
