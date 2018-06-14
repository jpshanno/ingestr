#' Ingest Multivariate El Nino Southern Oscillation Index  data
#'
#' \code{ingest_ENSO} ingests data from the NOAA Earth System Research
#' Laboratory Physical Sciences Division Mulivariate El Nino Southern
#' Oscillation Index. https://www.esrl.noaa.gov/psd/enso/mei/index.html
#' \strong{All ingest functions use the source file name as an identifying
#' column to track provenance and relate data and metadata read from files.}
#'
#' @param end.year The last year of data wanted.
#' @param header.info A logical indicating if header information is written to a
#'  separate data frame.
#' @param header.info.name A character indicating the object name for the
#'  metadata data.frame, defaults to "header_enso".
#'
#' @return A data frame.
#' @export


# Function ---------------------------

ingest_ENSO <- function(path = "http://www.esrl.noaa.gov/psd/enso/mei/table.html",   # URL of data
                        end.year = NULL,
                        header.info = TRUE,
                        header.info.name = "header_enso") {

               all_character(c("path", "header.info.name"))
               all_logical(c("header.info"))

               enso_pre <- XML::xpathSApply(XML::htmlParse(content(GET(path))),
                                            "//html/body/pre", XML::xmlValue)  # read the data

               start_year <- 1950   # define year range
               if(is.null(end.year)){
                 end.year <- as.numeric(format(Sys.Date(), "%Y"))
               }
               count_rows <- as.numeric(end.year+1) - start_year  # get the number of rows


               enso_cols <- scan(textConnection(enso_pre), skip=10, nlines=1,    # get header row
                                 what=character())
               enso <- read.csv(file=textConnection(enso_pre), skip=11, nrow = count_rows,
                                stringsAsFactors=F, sep="\t", header=FALSE, col.names=enso_cols)

               # creates header object
               if(header.info){
                  head_count_rows <- 11+count_rows

                  head_enso <- scan(textConnection(enso_pre), nlines=10, what=character(), sep="\n")
                  footer_enso <- scan(textConnection(enso_pre), skip=head_count_rows,
                                      what=character(), sep="\n")

                  header_enso <- c(head_enso, footer_enso)

                  assign(x = header.info.name,
                         value = header_enso,
                         envir = parent.frame())

                  }

               return(enso)

               }


