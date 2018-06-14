context("Test ingesting North Pacific Gyre Oscillation data")

test_file <- system.file("example_data", "www.o3d.org_npgo_npgo.html", package = "ingestr")

test_that("MONTH is in columns returned", {
  df <- ingestr::ingest_NPGO(test_file)
  expect_true("MONTH" %in% names(df))
})
