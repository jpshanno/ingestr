context("Test the header export functions")

test_that("hash_filename returns a sanitized string", {
  regex_match <- "[[:alnum:]_]{28}"
  temp_filename <- tempfile()
  expect_match(hash_filename(temp_filename),
               regex_match)
})
