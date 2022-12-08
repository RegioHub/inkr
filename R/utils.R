db_dir <- function() system.file("db", package = "inkr")

db_file <- function() file.path(db_dir(), "inkar.duckdb")

db_exists <- function() file.exists(db_file())

dbExecute_verbose <- function(conn, statement, verbose, ...) {
  if (verbose) {
    msg <- strtrim(statement, max(getOption("width") - 3L, 0L))
    if (!endsWith(msg, ";")) msg <- paste0(msg, "...")
    message(msg)
  }
  DBI::dbExecute(conn, statement, ...)
}
