
<!-- README.md is generated from README.Rmd. Please edit that file -->
rcpv
====

R package for working with Common Procurement Vocabulary (CPV) codes. As described on [SIMAP](https://simap.ted.europa.eu/cpv "information system for public procurement (fr. système d'information pour les marchés publics)"):

> The CPV establishes a single classification system for public procurement aimed at standardising the references used (...) to describe the subject of procurement contracts.

> The CPV consists of a main vocabulary for defining the subject of a contract, and a supplementary vocabulary for adding further qualitative information. The main vocabulary is based on a tree structure comprising codes of up to 9 digits (an 8 digit code plus a check digit) associated with a wording that describes the type of supplies, works or services forming the subject of the contract.

Installation
------------

To install directly from GitHub:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("kaftanowicz/rcpv")
```

Usage
-----

The main function exported by this package is `describe_cpv`, which repairs given CPV codes if they are broken, classifies them at selected level of aggregation and returns their description in chosen language, shortened to desired number of characters.

``` r
cpv <- c("45212212-5", "34962220-6", "15961100-3")

describe_cpv(cpv)
#> [1] "Construction work for swimming pool"
#> [2] "Air-traffic control systems"        
#> [3] "Lager"
describe_cpv(cpv, class_level = 5)
#> [1] "Construction work for sports facilities"
#> [2] "Air-traffic control"                    
#> [3] "Lager"
describe_cpv(cpv, class_level = 4)
#> [1] "Construction work for buildings relating to leisure, sports, culture, lodging and restaurants"
#> [2] "Air-traffic control equipment"                                                                
#> [3] "Beer"
describe_cpv(cpv, class_level = 3)
#> [1] "Building construction work" "Airport equipment"         
#> [3] "Malt beer"
describe_cpv(cpv, class_level = 2)
#> [1] "Works for complete or part construction and civil engineering work"
#> [2] "Miscellaneous transport equipment and spare parts"                 
#> [3] "Beverages, tobacco and related products"
describe_cpv(cpv, class_level = 1)
#> [1] "Construction work"                                           
#> [2] "Transport equipment and auxiliary products to transportation"
#> [3] "Food, beverages, tobacco and related products"
describe_cpv(cpv, class_level = 1, max_nchar = 30)
#> [1] "Construction work"           "Transport equipment..."     
#> [3] "Food, beverages, tobacco..."

describe_cpv(cpv, lang = "DE")
#> [1] "Bauarbeiten für Schwimmbäder" "Flugsicherungssysteme"       
#> [3] "Lagerbier"
```

Several of the functions called inside `describe_cpv` - `is_correct_cpv`, `correct_cpv`, `classify_cpv`, `convert_cpv`, `shorten_cpv`, `shorten_desc` - are available to the user on their own.

``` r
cpv <- c("45212212-5", "45212212  - 5", "452122125", "45.21.22.12.5")

is_correct_cpv(cpv)
#> [1]  TRUE FALSE FALSE FALSE

correct_cpv(cpv)
#> [1] "45212212" "45212212" "45212212" "45212212"
```

``` r
cpv <- "45.21.22.12.5"
classify_cpv(cpv, class_level = 1)
#> [1] "45000000"
```

``` r
cpv_2003 <- "01111000-8"
(cpv_2007 <- convert_cpv(cpv_2003, from2003to2007 = TRUE))
#> [1] "03211000-3"
convert_cpv(cpv_2007, from2003to2007 = FALSE)
#> [1] "01111000-8"
```

``` r
li <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
shorten_desc(li, max_nchar = 30, ending = "...")
#> [1] "Lorem ipsum dolor sit amet..."
```
