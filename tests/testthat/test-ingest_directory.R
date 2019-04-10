context("Test ingesting a directory of uniform files")

test_dir <- system.file("example_data", package = "ingestr")
df <- ingestr::ingest_directory(test_dir, pattern = ".csv")

test_that("output is a dataframe", {
  expect_s3_class(df, "data.frame")
})

