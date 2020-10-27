context("Test ingesting Tecan i-control plate reader data")

test_file <- system.file("example_data", "icontrol_384_od_kin.xlsx", package = "ingestr")
df <- ingestr::ingest_icontrol_kinetic_sheet(input.source=test_file, input.sheet=1)

test_that("768 rows are returned (2 cycles of 384 wels)", {
  expect_true(nrow(df)==2*384)
})


test_that("Reads are returned", {
  expect_true("kinetic_value" %in% names(df))
})

test_that("Reads are numeric", {
  expect_true(class(df[["kinetic_value"]]) == "numeric")
})
