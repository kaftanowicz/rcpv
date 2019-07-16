context("Function convert_cpv - converting between 2003 and 2007 standards")
library(rcpv)

test_that("Conversion 2003 -> 2007 - long code", {
  expect_equal(convert_cpv(code = "01111000-8", from2003to2007 = TRUE), "03211000-3")
})

test_that("Conversion 2003 -> 2007 - short code", {
  expect_equal(convert_cpv(code = "01111100", from2003to2007 = TRUE), "03211100")
})

test_that("Conversion 2007 -> 2003 - long code", {
  expect_equal(convert_cpv(code = "03211000-3", from2003to2007 = FALSE), "01111000-8")
})

test_that("Conversion 2007 -> 2003 - short code", {
  expect_equal(convert_cpv(code = "03211100", from2003to2007 = FALSE), "01111100")
})

test_that("Conversion 2003 -> 2007 - handling invalid inputs", {
  expect_identical(convert_cpv(code = "Lorem Ipsum", from2003to2007 = TRUE), "Lorem Ipsum")
  expect_equal(convert_cpv(code = "Lorem Ipsum", from2003to2007 = TRUE,
                           keep_not_converted = FALSE), NA)

})

test_that("convert_cpv handles NA properly", {
  expect_equal(convert_cpv(code = NA, from2003to2007 = TRUE), NA)
})
