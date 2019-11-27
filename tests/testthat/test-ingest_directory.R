context("Test ingesting a directory of uniform files")

test_direc <- system.file("example_data/campbell_directory", package = "ingestr")
df <- ingest_directory(test_direc, ingest.function = ingest_campbell, pattern = ".dat")
test_header <- ingest_header(test_direc) 
test_length <- length(list.files(test_direc))

test_that("output is a dataframe", {
  expect_s3_class(df, "data.frame")
})

# test that there are equal number of lines in header as the files that you read in
test_that("number of lines equals number of files read",{
  expect_equal(length(test_header)-1, test_length)
})

