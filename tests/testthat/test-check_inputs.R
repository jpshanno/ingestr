context("Test the check_inputs function")

test_that("all_logical checks for booleans", {
  bool_var <- TRUE
  not_bool_var <- 1
  all_logical(c("bool_var", "bool_var"))
  expect_error(all_logical(c("not_bool_var", "bool_var")))
})

test_that("all_character checks for characters", {
  valid_var <- "happy"
  invalid_var <- TRUE
  all_character(c("valid_var", "valid_var"))
  expect_error(all_character(c("invalid_var", "valid_var")))
})

test_that("all_numeric checks for numbers", {
  valid_var <- 1
  invalid_var <- "1"
  all_numeric("valid_var")
  expect_error(all_numeric(c("invalid_var", "valid_var")))
})

test_that("all_list checks for lists", {
  valid_var <- list(1, 2, 3)
  invalid_var <- 1
  all_list("valid_var")
  expect_error(all_list(c("invalid_var", "valid_var")))
})

test_that("only allowed classes are allowed", {
  a_var <- 1
  expect_error(check_inputs("a_var", "integer"))
})
