#' Ingest Multivariate El Nino Southern Oscillation Index data.
#'
#' \code{ingest_ENSO} ingests data from the NOAA Earth System Research
#' Laboratory Physical Sciences Division Mulivariate El Nino Southern
#' Oscillation Index. https://www.esrl.noaa.gov/psd/enso/mei/index.html
#' \strong{All ingest functions use the source file name as an identifying
#' column to track provenance and relate data and metadata read from files.}
#'
#' @param path Character indicating the URI to the HTML representation of the data.
#' @param end.year Four digit integer indicating the last year of data wanted.
#' @param header.info A logical indicating if header information is written to a
#'   separate data frame.
#' @param header.info.name A character indicating the object name for the
#'   metadata data.frame, defaults to "header_enso".
#'
#' @return A data frame.
#' @export
#' df_enso <- ingest_ENSO()  # reads in all the data from start date to present
#' df_enso1 <- ingest_ENSO(end.year=2000)  # reads in the data from start date to the year 2000
#' header_enso  # prints the header (and if applicable footer) information
#'

ingest_ENSO <- function(path = "http://www.esrl.noaa.gov/psd/enso/mei/table.html",   # URL of data
                        end.year = NULL,
                        header.info = TRUE,
                        header.info.name = "header_enso") {

               all_character(c("path", "header.info.name"))
               all_logical(c("header.info"))

               enso_pre <- XML::xpathSApply(XML::htmlParse(httr::content(httr::GET(path))),
                                            "//html/body/pre", XML::xmlValue)  # read the data

               start_year <- 1950   # define year range
               if(is.null(end.year)){
                 end.year <- as.numeric(format(Sys.Date(), "%Y"))
               }
               count_rows <- as.numeric(end.year+1) - start_year  # get the number of rows


               enso_cols <- scan(textConnection(enso_pre), skip=10, nlines=1,    # get header row
                                 what=character())
               enso <- utils::read.csv(file=textConnection(enso_pre), skip=11, nrow = count_rows,
                                       stringsAsFactors=F, sep="\t", header=FALSE, col.names=enso_cols)
               enso$input_source <- path

               # creates header object
               if(header.info){
                  head_count_rows <- 11+count_rows

                  head_enso <- scan(textConnection(enso_pre), nlines=10, what=character(), sep="\n")
                  footer_enso <- scan(textConnection(enso_pre), skip=head_count_rows,
                                      what=character(), sep="\n")

                  head1_enso <- c(head_enso, footer_enso)

                  header_enso <-  data.frame(input_source = path, table_header = paste(head1_enso, collapse = " "))

                  assign(x = header.info.name,
                         value = utils::str(header_enso),
                         envir = parent.frame())

                  }

               return(enso)

               }


