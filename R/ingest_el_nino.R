#' Ingest Multivariate El Nino Southern Oscillation Index  data
#'
#' \code{ingest_ENSO} ingests data from the NOAA Earth System Research
#' Laboratory Physical Sciences Division Mulivariate El Nino Southern
#' Oscillation Index. https://www.esrl.noaa.gov/psd/enso/mei/index.html
#' \strong{All ingest functions use the source file name as an identifying
#' column to track provenance and relate data and metadata read from files.}
#'
#' @param end_year The last year of data wanted.
#'
#' @return A data frame
#' @export


# Function ---------------------------

ingest_ENSO <- function(end_year = NULL) {
               path <- "http://www.esrl.noaa.gov/psd/enso/mei/table.html"   # URL of data
               enso_pre <- XML::xpathSApply(XML::htmlParse(content(GET(path))),
                                            "//html/body/pre", XML::xmlValue)  # read the data

               start_year <- 1950   # define year range
               if(is.null(end_year)){
                 end_year <- as.numeric(format(Sys.Date(), "%Y"))
               }
               count_rows <- as.numeric(end_year+1) - start_year  # get the number of rows


               enso_cols <- scan(textConnection(enso_pre), skip=10, nlines=1,    # get header row
                                 what=character())
               enso <- read.csv(file=textConnection(enso_pre), skip=11, nrow = count_rows,
                                stringsAsFactors=F, sep="\t", header=FALSE, col.names=enso_cols)

               }


