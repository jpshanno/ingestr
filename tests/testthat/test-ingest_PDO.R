context("Test ingesting Pacific decadal oscillation data")

test_file <- system.file("example_data", "jisao.washington.edu_pdo_PDO.latest.txt", package = "ingestr")

test_that("AUG is in list of months returned", {
  df <- ingestr::ingest_PDO(test_file)
  expect_true("AUG" %in% names(df))
})
