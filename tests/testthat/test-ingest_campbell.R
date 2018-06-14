context("Test ingesting Campbell Scientific Logger data")

test_file <- system.file("example_data", "campbell_scientific_tao5.dat", package = "ingestr")
df <- ingestr::ingest_campbell(test_file)

test_that("TIMESTAMP is in columns returned", {
  expect_true("TIMESTAMP" %in% names(df))
})

test_that("TIMESTAMP column is a date type", {
  classes <- lapply(df, class)
  ts_class <- classes[["TIMESTAMP"]]
  expect_true(grep("POSIXct", ts_class) > 0)
})
