context("Test ingesting Solinst XLE files")

xle_file <- system.file("example_data", "solinst.xle", package = "ingestr")

test_that("A dataframe is returned with date, time, and channel columns", {
  df <- ingest_xle(input.source = xle_file)
  expect_s3_class(df, "data.frame")
  expect_true(all(c("sample_time", "sample_date", "sample_millisecond") %in% names(df)))
  expect_gt(length(names(df)), 3)
})

test_that("Collapsing to timestamp column works", {
  df <- ingest_xle(input.source = xle_file,
                   collapse.timestamp = TRUE)
  expect_true("sample_timestamp" %in% names(df))
})


