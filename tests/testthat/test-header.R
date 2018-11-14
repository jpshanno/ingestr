context("Test the header export functions")

input_source <-
  "this is my problematic_filename$"
header_info <-
  data.frame(x = "a",
             sn = "456542")

test_that("hash_filename returns a sanitized string", {
  regex_match <- "[[:alnum:]_]{28}"
  expect_match(hash_filename(input_source),
               regex_match)
})

test_that("export_header creates a file", {
  export_header(header.info = header_info,
                input.source = input_source)
  expect_true(any(grepl(hash_filename(input_source), list.files(tempdir()))))
})

test_that("ingest_header reads in a file", {
  header <-
    ingest_header(input_source)
  expect_s3_class(header,
                  "data.frame")
})
