library(testthat)
library(rcpv)

test_check("rcpv")
test_file("tests/testthat/test-convert_cpv.R")
test_file("tests/testthat/test-correct_cpv.R")
test_file("tests/testthat/test-describe_cpv.R")
