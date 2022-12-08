source(here::here("data-raw/z00-setup.R"))

zip_url <- "https://www.bbr-server.de/imagemap/inkar/download/inkar_2021.zip"
zip_name <- stringi::stri_extract_first_regex(zip_url, "(?<=\\/)\\w+\\.zip$")

download.file(zip_url, here::here("data-raw", zip_name))

zipped_csv_info <- unzip(here::here("data-raw", zip_name), list = TRUE)

csv_name <- zipped_csv_info$Name[1]

if (!file.exists(here::here("data-raw", csv_name)) ||
    as.Date(file.info(here::here("data-raw", csv_name))$mtime) != as.Date(zipped_csv_info$Date)[1]) {
  unzip(
    here::here("data-raw", zip_name),
    files = csv_file,
    exdir = here::here("data-raw"),
    unzip = getOption("unzip")
  )
}

inkar <- read_csv2(here::here("data-raw", csv_name), col_types = "ciccicccn", lazy = FALSE)

dbWriteTable(con, "inkar_raw", inkar)

dbDisconnect(con, shutdown = TRUE)
