context("Test ingesting PP Systems EGM-4 data")

test_file <- system.file("example_data", "egm4.dat", package = "ingestr")
df <- ingestr::ingest_egm4(test_file)

test_that("A dataframe is created", {
  expect_s3_class(df, "data.frame")
})

test_that("Columns are renamed based on probe type", {
  expect_true(any(grepl("assimilation_gCO2_m2_hr", names(df))))
})

