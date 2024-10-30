source("data-raw/z00-setup.R")

zip_url <- "https://www.bbr-server.de/imagemap/inkar/download/inkar_2024.zip"

zip_path <- "data-raw/inkar_2024/inkar_2024.zip"

download.file(zip_url, zip_path)

unzip(zip_path)

polars::pl$scan_csv(
  "inkar_2024/inkar_2024.csv",
  separator = ";",
  dtypes = list(
    Bereich = "String",
    ID = "Int32",
    Kuerzel = "String",
    Indikator = "String",
    Raumbezug = "String",
    Kennziffer = "String",
    Name = "String",
    Zeitbezug = "String",
    Wert = "String"
  )
)$with_columns(
  polars::pl$col("Wert")$
    str$replace(",", ".", literal = TRUE)$
    cast(polars::pl$dtypes$Float64)
)$sink_parquet("inkar_2024/inkar_2024.parquet")

dbExecute(
  con,
  "CREATE TABLE inkar_raw AS
    SELECT * FROM 'data-raw/inkar_2024/inkar_2024.parquet'"
)

dbDisconnect(con, shutdown = TRUE)
