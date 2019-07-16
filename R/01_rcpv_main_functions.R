#' Validation of CPV codes
#'
#' Checks if given argument is an existing CPV code, either a current one or
#' one from the 2003 version.
#'
#' @param code vector of CPV codes (character)
#' @return vector (logical)
#'
#' @export
#'
is_correct_cpv <- function(code) {
  (code %in% c(corr_codes[["CODE_2003"]], corr_codes[["CODE_2007"]])) |
    shorten_cpv(code) %in% cpv_codes[["CODE_SHORT"]]
}

#' Description of a CPV codes
#'
#' Tries to correct malformed ones. Allows for classification.
#'
#' @param code vector of CPV codes (character)
#' @param lang two-letter language code, default is "EN" for English (character)
#' @param class_level level of CPV classification,
#' corresponding to Division, Group, Class, Category and Subcategory;
#' level 1 (Division) is the most general, level 5 (Subcategory)
#' the most specific categorisation. If NULL (default), no classification is done. (NULL or integer from 1 to 5)
#' @param max_nchar maximum number of characters in description for shortening.
#' If NULL (default), no shortening is performed. (NULL or integer)
#'
#' @return vector of descriptions in selected language (character)
#'
#' @export
#' @import data.table
#'
describe_cpv <- function(code, lang = c("EN", "BG", "CS", "DA", "DE", "EL", "ES", "ET", "FI", "FR", "GA", "HR", "HU", "IT", "LT", "LV", "MT", "NL", "PL", "PT", "RO", "SK", "SL", "SV"),
                         class_level = NULL,
                         max_nchar = NULL) {
  lang <- match.arg(lang)
  code <- correct_cpv(code,
                      leading_digits = TRUE,
                      convert = TRUE,
                      shorten = TRUE)
  code <- classify_cpv(code, class_level = class_level)
  # Finding description
  decoding_dt <- cpv_codes[, c("CODE_SHORT", lang),
                           with = FALSE]
  decoded <- match_code(code, decoding_dt)
  invalid_index <- !is.na(code) & is.na(decoded)
  if (any(invalid_index)) {
    warning(sprintf("Invalid codes detected (%.2f%% of the cases), returning NA in place of their description: ",
                    100*sum(invalid_index)/length(code)),
            paste(sort(unique(code[invalid_index])), collapse = ", "))
  }
  if (!is.null(max_nchar)) {
    decoded <- shorten_desc(decoded, max_nchar = max_nchar, ending = "...")
  }
  return(decoded)
}


#' Conversion of CPV codes
#'
#' Finds corresponding CPV codes between 2003 and 2007 versions.
#'
#' @param code vector of CPV codes (character)
#' @param from2003to2007 if TRUE, finds 2007 version code for given 2003 version code;
#' if FALSE, the other way around (logical)
#' @param keep_not_converted if TRUE, codes for which conversion failed are returned
#' as they are; if FALSE, returns NA in their place (logical)
#'
#' @return vector of converted CPV codes (character)
#'
#' @export
#'
convert_cpv <- function(code, from2003to2007 = TRUE,
                        keep_not_converted = TRUE) {
  if (from2003to2007) {
    conversion_dt <- corr_codes
    convert_index <- is_2003_cpv(code)
  } else {
    conversion_dt <- corr_codes[, c(2, 1)] # reversing column order
    convert_index <- is_2007_cpv(code)
  }
  if (keep_not_converted) {
    converted <- code
  } else {
    converted <- rep(NA, times = length(code))
  }
  if (any(convert_index)) {
    converted[convert_index] <- match_code(code[convert_index], conversion_dt)
  }
  return(converted)
}

#' Correction of CPV codes
#'
#' Attempts to correct CPV codes in case they are corrupted or written in unusual way
#' (e.g. "73.00.00.00-2" or "37440000 - 4").
#' If shorten = TRUE, shortens them as well (i.e. drops the dash and following check digit).
#'
#' @param code vector of possibly corrupted CPV codes (character)
#' @param leading_digits if the code is shorter than usual, does that mean that the digits provided
#' are the first "n" leading digits? If FALSE, it assumes trailing digits instead. (logical)
#' @param convert attempt to convert old codes into current ones? (logical)
#' @param shorten remove "-" and check digit that follows it? (logical)
#'
#' @return vector of code CPV codes (character)
#'
#' @export
#'
correct_cpv <- function(code,
                        leading_digits = TRUE,
                        convert = TRUE,
                        shorten = TRUE) {
  if (any(is.na(code))) {
    warning(sprintf("Missing values (NA) of CPV codes in %.2f%% of cases",
                    100*sum(is.na(code))/length(code)))
  }

  # Removing everything except the digits
  code <- gsub("[^0-9]", "", as.character(code))

  # If there are fewer than 8 digits, then either we got first "n" leading digits
  # or an integer had its leading 0s dropped because of number formatting
  # during earlier processing. No way to tell, so decision is up to the user
  if (leading_digits) {
    code <- stringi::stri_pad_right(code, 8, 0) # add trailing 0s
  } else {
    code <- stringi::stri_pad_left(code, 8, 0) # add leading 0s
  }

  # 9 digits mean the dash separating the code proper
  # from the check digit has been dropped
  # (possibly in the first step of this correction)
  missed_dash_index <- (!is.na(code) & nchar(code) == 9)
  code[missed_dash_index] <- paste(substr(code[missed_dash_index], 1, 8),
                                   substr(code[missed_dash_index], 9, 9),
                                   sep = "-")

  # Dealing with those that did not get corrected properly
  invalid_index <- !is.na(code) & !is_correct_cpv(code)
  if (any(invalid_index)) {
    warning(sprintf("Correction failed for %.2f%% of the cases - codes: ",
                    100*sum(invalid_index)/length(code)),
            paste(sort(unique(code[invalid_index])), collapse = ", "))
  }
  if (convert) {
    code <- convert_cpv(code, from2003to2007 = TRUE,
                        keep_not_converted = TRUE)
  }
  if (shorten) {
    code <- shorten_cpv(code)
  }
  return(code)
}


#' Classification of CPV codes
#'
#' Reduces CPV codes to their higher level class.
#'
#' @param code vector of CPV codes (character)
#' @param class_level (integer from 1 to 5) level of CPV classification,
#' corresponding to Division, Group, Class, Category and Subcategory;
#' level 1 (Division) is the most general, level 5 (Subcategory)
#' the most specific categorisation. If NULL, no classification is done.
#'
#' @return vector of CPV codes aggregated to (class_level + 1) significant digits (character)
#'
#' @export
#'
classify_cpv <- function(code, class_level = NULL) {
  if (!is.null(class_level)) {
    if (class_level %in% 1:5) {
      # Choosing k = (level + 1) first digits from the code
      # and appending (8 - k) trailing 0s to get a proper 8-digit code
      return(stringi::stri_pad_right(substr(code,
                                            start = 1,
                                            stop = (class_level + 1)),
                                     8, 0))
    } else {
      warning("Argument class_level must be either NULL or an integer in 1:5 range; defaulting to NULL")
    }
  }
  return(code)
}


#' Shortening of description
#'
#' Shortens text to make it fit under chosen number of characters
#' without splitting words; adds chosen ending (e.g. "...") to indicate incomplete text.
#'
#' @param desc text vector (character)
#' @param max_nchar max. number of characters to be preserved, incl. chosen ending (integer)
#' @param ending indicator of text incompleteness; default = "..." (character)
#' @return shortened text vector (character)
#'
#' @export
#'
shorten_desc <- function(desc, max_nchar = 50, ending = "...") {
  if (!is.null(ending)) {
    max_nchar <- max_nchar - nchar(ending)
  }
  desc_split <- strsplit(desc, " ")
  nchar_cumsum <- lapply(desc_split, function(x) cumsum(nchar(x) + 1) - 1)
  nchar_chosen <- vapply(nchar_cumsum, function(x) max(x[x <= max_nchar]), FUN.VALUE = numeric(1))
  desc_short <- substr(desc, 1, nchar_chosen)
  desc_short <- gsub("(,|;| *and)$", "", desc_short)
  which_shortened <- nchar(desc) > max_nchar
  which_shortened[is.na(which_shortened)] <- FALSE
  desc_short[which_shortened] <- paste0(desc_short[which_shortened], ending)
  return(desc_short)
}
