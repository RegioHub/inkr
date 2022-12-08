make_clean_names_de <- function(x) {
  x |>
    stringi::stri_trans_general("de-ASCII") |>
    snakecase::to_snake_case()
}

remote_to_local <- function(url) {
  tmp_file <- tempfile()
  utils::download.file(url, tmp_file)
  tmp_file
}
