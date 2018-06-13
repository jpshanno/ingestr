context("Test ingesting Pacific decadal oscillation data")
library(ingestr)

test_that("AUG is in list of months returned", {
  df <- ingest_PDO()
  expect_true("AUG" %in% names(df))
})
