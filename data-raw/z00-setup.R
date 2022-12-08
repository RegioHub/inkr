library(tidyverse)
library(DBI)
source(here::here("data-raw/zaa-utils.R"))

con <- dbConnect(duckdb::duckdb(), dbdir = here::here("data-raw/inkar.duckdb"))
