#' INKAR data
#'
#' Tables in the INKAR database
#'
#' @format A list containing connections to the tables in the local INKAR
#'   database.
#' \describe{
#'   \item{`_indikatoren`}{ID, abbreviation, name, domain and description of
#'     individual indicators.}
#'   \item{`_regionen`}{spatial reference, official code and name of individual
#'     regions.}
#'   \item{other tables, e.g. `absolutzahlen`}{Values by region and
#'     time. Each table contains values for a certain INKAR domain (Bereich).
#'     Column names correspond to the `kuerzel` column in the `_indikatoren`
#'     table.}
#' }
#' The DBI connection to the local database is stored as an attribute of the
#'   `inkar` object and can be accessed with `attr(inkar, "con")`.
"inkar"

#' NUTS-3 regions (districts/_Kreise_)
#'
#' Lookup table with NUTS-3 code and _Kreiskennziffer_ for all 401 NUTS-3
#'   regions in Germany
"kreise"
