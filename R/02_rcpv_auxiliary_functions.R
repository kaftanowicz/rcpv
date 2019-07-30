#' Checks if given argument is a CPV code from 2003 version.
#'
#' @param code vector of CPV codes (character)
#' @return vector (logical)
#'
#' @keywords internal
#'
is_2003_cpv <- function(code) {
  code %in% setdiff(corr_codes[["CODE_2003"]], corr_codes[["CODE_2007"]])
}

#' Checks if given argument is a CPV code from the current (2007) version.
#'
#' @param code vector of CPV codes (character)
#' @return vector (logical)
#'
#' @keywords internal
#'
is_2007_cpv <- function(code) {
  code %in% setdiff(corr_codes[["CODE_2007"]], corr_codes[["CODE_2003"]])
}

#' Returns a vector of 2-letter codes of the languages in which CPV codes' descriptions are available.
#'
#' @return invisible(NULL)
#'
#' @keywords internal

lang_available <- function() {
  return(sort(setdiff(colnames(cpv_codes),
                 c("CODE", "CODE_SHORT"))))
}

#' Matches values from a data table to the ones in a vector
#' while preserving order.
#'
#' @param code vector of CPV codes (character)
#' @param dt_to_match (data.table) with first column containing CPV codes
#' to be matched with the code vector
#' @param code_col_index which column of dt_to_match contains CPV codes? (integer)
#' @param val_col_index which column of dt_to_match contains values
#' to be returned after matching? (integer)
#'
#' @return vector of values from the chosen column (character)
#'
#' @keywords internal
#' @import data.table
#'
match_code <- function(code, dt_to_match, code_col_index = 1, val_col_index = 2) {
  code_dt <- data.table(code)
  match_on <- colnames(dt_to_match)[code_col_index]
  colnames(code_dt)[1] <- match_on
  return((dt_to_match[code_dt, on = match_on])[[val_col_index]])
}
