
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![DOI](https://zenodo.org/badge/575766849.svg)](https://zenodo.org/badge/latestdoi/575766849)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

# inkr

{inkr} provides efficient and automated access to regional data from
[inkar.de](https://www.inkar.de) via a local relational database.

Data from [INKAR](https://www.inkar.de)[^1] are normalised[^2] and
imported into a local [DuckDB](https://duckdb.org) database. On attach
(e.g. with `library(inkr)`), a [DBI](https://dbi.r-dbi.org/) connection
is made from R to this database.

## Installation

You can install {inkr} like so:

``` r
remotes::install_github("RegioHub/inkr")
```

## Usage

A local database containing the INKAR data must be built before first
use:

``` r
library(inkr)

inkar_db_build()
```

Afterwards, all the tables in the local INKAR database are accessible in
R via an object named `inkar`.[^3]

Currently, `inkar` contains the following tables:

``` r
# See `?inkar` for more details
names(inkar)
#>  [1] "_indikatoren"                        
#>  [2] "_regionen"                           
#>  [3] "absolutzahlen"                       
#>  [4] "arbeitslosigkeit"                    
#>  [5] "bauen_und_wohnen"                    
#>  [6] "beschaeftigung_und_erwerbstaetigkeit"
#>  [7] "bevoelkerung"                        
#>  [8] "bildung"                             
#>  [9] "europa"                              
#> [10] "flaechennutzung_und_umwelt"          
#> [11] "medizinische_und_soziale_versorgung" 
#> [12] "oeffentliche_finanzen"               
#> [13] "privateinkommen_und_private_schulden"
#> [14] "raumwirksame_mittel"                 
#> [15] "sdg_indikatoren_fuer_kommunen"       
#> [16] "siedlungsstruktur"                   
#> [17] "sozialleistungen"                    
#> [18] "verkehr_und_erreichbarkeit"          
#> [19] "wirtschaft"                          
#> [20] "zentrale_orte_monitoring"
```

You can use {dplyr} to work with the tables in `inkar` as if they were
in-memory data frames, e.g.:

``` r
library(dplyr)

inkar$`_regionen` |>
  distinct(raumbezug) |>
  arrange(raumbezug)
#> # Source:     SQL [?? x 1]
#> # Database:   DuckDB v1.1.2 [root@Darwin 24.0.0:R 4.4.1//Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library/inkr/db/inkar.duckdb]
#> # Ordered by: raumbezug
#>    raumbezug                                  
#>    <chr>                                      
#>  1 Arbeitsmarktregionen                       
#>  2 BBSR-Mittelbereiche                        
#>  3 Braunkohlereviere (auch nicht förderfähige)
#>  4 Bund                                       
#>  5 Bundesländer                               
#>  6 EU27                                       
#>  7 Gemeinden                                  
#>  8 Gemeindeverbände (Verwaltungsgemeinschaft) 
#>  9 Großstadtregionaler Einzugsbereich         
#> 10 Großstadtregionen                          
#> # ℹ more rows

inkar$`_indikatoren` |>
  count(bereich)
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB v1.1.2 [root@Darwin 24.0.0:R 4.4.1//Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library/inkr/db/inkar.duckdb]
#>    bereich                                 n
#>    <chr>                               <dbl>
#>  1 SDG-Indikatoren für Kommunen           41
#>  2 Medizinische und soziale Versorgung    20
#>  3 Absolutzahlen                          11
#>  4 Siedlungsstruktur                       5
#>  5 Wirtschaft                             24
#>  6 Europa                                 89
#>  7 Arbeitslosigkeit                       34
#>  8 Bauen und Wohnen                       21
#>  9 Flächennutzung und Umwelt              17
#> 10 Öffentliche Finanzen                   10
#> # ℹ more rows
```

### Example: median income

Find the indicator ID for the median income:

``` r
inkar$`_indikatoren` |>
  filter(kurzname == "Medianeinkommen")
#> # Source:   SQL [1 x 10]
#> # Database: DuckDB v1.1.2 [root@Darwin 24.0.0:R 4.4.1//Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library/inkr/db/inkar.duckdb]
#>   merk_id  m_id rubrik    bereich kuerzel kurzname name  algorithmus anmerkungen
#>     <int> <int> <chr>     <chr>   <chr>   <chr>    <chr> <chr>       <chr>      
#> 1   20287  6003 Raumbeob… Privat… m_ek    Mediane… Medi… Medianeink… "Median de…
#> # ℹ 1 more variable: statistische_grundlagen <chr>
```

5 counties with the highest median income in 2021:

``` r
inkar$privateinkommen_und_private_schulden |>
  filter(raumbezug == "Kreise", zeitbezug == 2021) |>
  select(name, m_ek) |>
  arrange(desc(m_ek)) |>
  head(5)
#> # Source:     SQL [5 x 2]
#> # Database:   DuckDB v1.1.2 [root@Darwin 24.0.0:R 4.4.1//Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/library/inkr/db/inkar.duckdb]
#> # Ordered by: desc(m_ek)
#>   name                       m_ek
#>   <chr>                     <dbl>
#> 1 Erlangen                  5091.
#> 2 Wolfsburg, Stadt          4970.
#> 3 Ingolstadt                4966.
#> 4 Stuttgart, Stadtkreis     4750.
#> 5 München, Landeshauptstadt 4681.
```

## Citation

To cite package ‘inkr’ in publications use:

Nguyen HL (2024). {inkr}: Local Access from R to All INKAR Data.
<https://doi.org/10.5281/zenodo.7643755>,
<https://github.com/RegioHub/inkr>

A BibTeX entry for LaTeX users is

    @Manual{,
      title = {{inkr}: Local Access from R to All INKAR Data},
      doi = {10.5281/zenodo.7643755},
      author = {H. Long Nguyen},
      year = {2024},
      version = {0.2.0},
      url = {https://github.com/RegioHub/inkr},
    }

## Copyright notice

The data are made available by the [*Bundesinstitut für Bau-, Stadt- und
Raumforschung* (BBSR)](https://www.bbsr.bund.de) in accordance with the
[data licence Germany – attribution – version
2.0](https://www.govdata.de/dl-de/by-2-0).

This package is in no way officially related to or endorsed by BBSR.

[^1]: downloaded via
    [“Datenbankdownload”](https://www.bbr-server.de/imagemap/inkar/download/inkar_2021.zip)

[^2]: i.e. not a single table with 21 million rows

[^3]: More precisely, `inkar` contains connections to the tables in the
    DuckDB database via [DBI](https://dbi.r-dbi.org/) and
    [dbplyr](https://dbplyr.tidyverse.org/).
