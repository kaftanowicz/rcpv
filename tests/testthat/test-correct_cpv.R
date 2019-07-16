context("Function correct_cpv")
library(rcpv)

test_that("Correction without shortening", {
  expect_equal(correct_cpv(code = "03211700", shorten = FALSE), "03211700")
  expect_equal(correct_cpv(code = "03211700-1", shorten = FALSE), "03211700-1")
})

test_that("Correction with shortening", {
  expect_equal(correct_cpv(code = "03211700", shorten = TRUE), "03211700")
  expect_equal(correct_cpv(code = "03211700-1", shorten = TRUE), "03211700")
})

test_that("correct_cpv handles NA properly", {
  expect_warning(correct_cpv(code = NA, shorten = TRUE))
  expect_identical(correct_cpv(code = NA, shorten = TRUE), NA_character_)
})
