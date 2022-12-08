.onAttach <- function(libname, pkgname) {
  inkar_db_attach()
}

.onDetach <- function(libname) {
  inkar_db_disconnect()
}
