context("Test ingesting El Nino Southern Oscillation Index data")

test_file <- system.file("example_data", "www.esrl.noaa.gov_psd_enso_mei_table.html", package = "ingestr")

test_that("JULAUG is in columns returned", {
  df <- ingestr::ingest_ENSO(test_file)
  expect_true("JULAUG" %in% names(df))
})
