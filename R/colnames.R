#' Rename columns to INKAR indicator names instead of x123 etc.
#'
#' @inherit dplyr::rename_with return params
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' inkar$bevoelkerung |>
#'   filter(zeitbezug == 2019) |>
#'   select(region_id, x111:x115) |>
#'   rename_with_inkar_indicators()
#' }
rename_with_inkar_indicators <- function(.data) {
  .data |>
    dplyr::rename_with(get_inkar_indicator_names, dplyr::matches("^x\\d{1,3}$"))
}

#' @importFrom dplyr .data
get_inkar_indicator_names <- function(x) {
  x_ids <- as.integer(stringi::stri_extract_first_regex(x, "\\d{1,3}$"))

  inkar$`_indikatoren` |>
    dplyr::right_join(data.frame(id = x_ids), by = c("id"), copy = TRUE) |>
    dplyr::pull(.data$kurzname) |>
    make_clean_names_de() |>
    dplyr::coalesce(x)
}

make_clean_names_de <- function(x) {
  x |>
    stringi::stri_trans_general("de-ASCII") |>
    snakecase::to_snake_case()
}
