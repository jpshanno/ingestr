context("Test ingesting a directory of uniform files")

test_dir <- system.file("example_data", package = "ingestr")

test_that("output is a dataframe", {
  df <- ingestr::ingest_directory(test_dir)
  expect_s3_class(df, "data.frame")
})

