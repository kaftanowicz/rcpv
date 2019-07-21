#' Updates or recreates .rda files in /data/ directory containing CPV codes descriptions.
#'
#' Provided to allow reproduction of internal package data.
#'
#' @param cpv_url URL to a file containing updated CPV descriptions
#' @param corr_url URL to a file containing updated 2003-2007 codes correspondences
#' @param package_path path to the source directory of this package
#'
#' @return TRUE if updated properly
#'
#' @keywords internal
#'
#' @import utils
#' @import data.table

update_data <- function(cpv_url = paste0("https://simap.ted.europa.eu/documents/10184/36234/",
                                         "cpv_2008_xls.zip"),
                        corr_url = paste0("http://simap.ted.europa.eu/documents/10184/36234/",
                                          "Correspondance_2003-2007_en.xlsx"),
                        package_path = "packages/rcpv") {
  # Download fresh data from the web and save to a temporary file
  temp_dir <- tempdir()
  cpv_fpath <- file.path(temp_dir, "cpv.zip")
  corr_codes_fpath <- file.path(temp_dir, "corr_codes.xlsx")

  download.file(cpv_url, cpv_fpath, mode = "wb")
  download.file(corr_url, corr_codes_fpath, mode = "wb")

  # Unzip to a temporary directory
  unzip(cpv_fpath, exdir = temp_dir, overwrite = TRUE)
  cpv_fpath <- list.files(temp_dir, full.names = TRUE)[grepl("^cpv.*\\.xlsx$", list.files(temp_dir))]

  cpv_codes <- data.table(readxl::read_excel(cpv_fpath, sheet = 1))
  sup_codes <- data.table(readxl::read_excel(cpv_fpath, sheet = 2))
  corr_codes <- data.table(readxl::read_excel(corr_codes_fpath, sheet = 1))

  # corr_codesespondence data for different ontologies (2003 vs 2007)
  corr_codes <- corr_codes[, c(1, 3)]
  colnames(corr_codes) <- c("CODE_2003", "CODE_2007")
  corr_codes <- data.table::na.omit(corr_codes)

  # Pre-defining data table column names as variables
  # to avoid 'no visible binding for global variable'
  # note from devtools::check()
  CODE <- NULL
  CODE_2003 <- NULL
  CODE_2007 <- NULL
  CODE_SHORT <- NULL
  CODE_SHORT_2003 <- NULL
  CODE_SHORT_2007 <- NULL

  # Shortening codes
  cpv_codes[, CODE_SHORT := shorten_cpv(CODE)]
  sup_codes[, CODE_SHORT := shorten_cpv(CODE)]

  corr_codes[, CODE_SHORT_2003 := shorten_cpv(CODE_2003)]
  corr_codes[, CODE_SHORT_2007 := shorten_cpv(CODE_2007)]

  # Reshaping the 2003-2007 correspondence table
  corr_codes <- rbindlist(list(corr_codes[, c("CODE_2003", "CODE_2007")],
                               corr_codes[, c("CODE_SHORT_2003", "CODE_SHORT_2007")]))

  # Save as R objects (data frames)


  #usethis::use_data(x, mtcars, internal = TRUE)

  save(cpv_codes, file = file.path(package_path, "data", "cpv_codes.rda"))
  save(sup_codes, file = file.path(package_path, "data", "sup_codes.rda"))
  save(corr_codes, file = file.path(package_path, "data", "corr_codes.rda"))

  # Delete temporary file and directory
  unlink(cpv_fpath)
  unlink(corr_codes_fpath)
  unlink(temp_dir, recursive = TRUE)
  return(TRUE)
}
