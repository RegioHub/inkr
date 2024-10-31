#' Import INKAR data into a local DuckDB database
#'
#' @param overwrite Overwrite existing database
#' @param verbose Should SQL statements for building the local database be printed?
#'
#' @export
inkar_db_build <- function(overwrite = FALSE, verbose = TRUE) {
  inkr_is_attached <- "inkr" %in% .packages()

  if (inkr_is_attached) detach("package:inkr", unload = TRUE)

  if (db_exists()) {
    if (overwrite) {
      file.remove(db_file())
    } else {
      stop(
        "Database file already exists.\n",
        "Run `inkar_db_build(overwrite = TRUE)` to overwrite."
      )
    }
  }

  con <- inkar_db(read_only = FALSE)

  readLines(system.file("db", "schema.sql", package = "inkr")) |>
    lapply(dbExecute_verbose, conn = con, verbose = verbose)

  readLines(system.file("db", "load.sql", package = "inkr")) |>
    sub(pattern = "$INST_PATH", replacement = system.file(package = "inkr"), fixed = TRUE) |>
    lapply(dbExecute_verbose, conn = con, verbose = verbose)

  DBI::dbDisconnect(con, shutdown = TRUE)

  if (inkr_is_attached) require(inkr, quietly = TRUE)

  invisible()
}

#' @export
print.inkar_db <- function(x, ...) {
  if (!"inkr" %in% .packages()) {
    # Because the value of inkar is overwritten on attach
    stop("inkr must be loaded/attached. Run `library(inkr)`.", call. = FALSE)
  }

  if (!db_exists() || length(x) != length(dir(db_dir(), "*.parquet"))) {
    message("Database not available. Run `inkar_db_build()` to build the database.")
    invisible(x)
  } else {
    attributes(x) <- NULL
    print(x)
  }
}

inkar_db <- function(read_only = TRUE) {
  DBI::dbConnect(duckdb::duckdb(), dbdir = db_file(), read_only = read_only)
}

inkar_db_attach <- function() {
  if (!db_exists()) {
    return()
  }

  con <- inkar_db()

  tbl_names <- DBI::dbListTables(con)

  tbls <- structure(
    lapply(stats::setNames(tbl_names, tbl_names), function(tbl) {
      dplyr::tbl(con, tbl)
    }),
    class = "inkar_db",
    con = con
  )

  assign("inkar", tbls, envir = as.environment("package:inkr"))
}

inkar_db_disconnect <- function() {
  con <- attr(inkar, "con")
  if (inherits(attr(inkar, "con"), "duckdb_connection")) DBI::dbDisconnect(con, shutdown = TRUE)
}

utils::globalVariables("inkar")
