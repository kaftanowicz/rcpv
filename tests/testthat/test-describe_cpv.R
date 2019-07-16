context("Function describe_cpv")
library(rcpv)

test_that("describe_cpv works correctly for regular codes", {
  expect_equal(describe_cpv(code = "03111500-7", lang = "EN"), "Sesame seeds")
  expect_equal(describe_cpv(code = "03111500-7", lang = "DE"), "Sesamsamen")
})

test_that("describe_cpv works correctly for simplified codes", {
  expect_equal(describe_cpv(code = "03211700", lang = "EN"), "Malt")
  expect_equal(describe_cpv(code = "03211700", lang = "DE"), "Malz")
})

test_that("describe_cpv handles improper arguments values", {
  expect_error(describe_cpv(code = "03111500", lang = "123!@#QWE"))
  expect_identical(describe_cpv(code = "qwerty", lang = "EN"), NA_character_)
})

test_that("describe_cpv handles NA properly", {
  expect_warning(describe_cpv(code = NA, lang = "EN"))
  expect_identical(describe_cpv(code = NA, lang = "EN"), NA_character_)
})
