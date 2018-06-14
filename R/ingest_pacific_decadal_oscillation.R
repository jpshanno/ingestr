#'Ingest Pacific Decadal Oscillation data
#'
#'\code{ingest_PDO} ingests data from the updated standardized values for the
#'PDO index, derived as the leading PC of monthly SST anomalies in the North
#'Pacific Ocean, poleward of 20N. The monthly mean global average SST anomalies
#'are removed to separate this pattern of variability from any "global warming"
#'signal that may be present in the data.  If you have any questions about this
#'time series, contact Nathan Mantua at: nate.mantua\@noaa.gov \strong{All
#'ingest functions use the source file name as an identifying column to track
#'provenance and relate data and metadata read from files.}
#'
#'@param end.year The last year of data wanted.
#'@param header.info A logical indicating if header information is written to a
#'  separate data frame.
#'@param header.info.name A character indicating the object name for the
#'  metadata data.frame, defaults to "header_pdo".
#'
#'
#'@return A data frame.  If header.info = TRUE a data.frame is created in the
#'  parent environment of the function.
#'@export
#'@examples
#'


# Ingest Function ---------------------------

ingest_PDO <- function(path = "http://jisao.washington.edu/pdo/PDO.latest",   # URL to the data
                       end.year = NULL,
                       header.info = TRUE,
                       header.info.name = "header_pdo") {

              all_character(c("path", "header.info.name"))
              all_logical(c("header.info"))

              pdo_raw <- xml2::read_html(path)                       # read in the data
              pdo_pre1 <- rvest::html_node(pdo_raw, "p")             # make data text
              pdo_pre2 <- rvest::html_text(pdo_pre1)

              start_year <- 1900   # define year range
              if(is.null(end.year)){
                 end.year <- as.numeric(format(Sys.Date(), "%Y"))
                }
              count_rows <- as.numeric(end.year+1) - start_year  # get the number of rows

              pdo_cols <- scan(textConnection(pdo_pre2), skip=31, nlines=1, what=character())# Get header row
              pdo_df <- utils::read.table(file=textConnection(pdo_pre2), skip=32, stringsAsFactors=F,
                                          sep="", nrow = count_rows,
                                          header=FALSE, col.names=pdo_cols, strip.white=TRUE, fill=TRUE) #
              pdo_df$YEAR <- substr(pdo_df$YEAR, 1, 4)  # removes asterisks from years 2002-present
              pdo_df$input_source <- path

              # creates header object
              if(header.info){
                 head_count_rows <- 33+count_rows

                 head_pdo <- scan(textConnection(pdo_pre2), nlines=31, what=character(), sep="\n")
                 footer_pdo <- scan(textConnection(pdo_pre2), skip=head_count_rows, nlines=31,
                                    what=character(), sep="\n")

                 head1_pdo <- c(head_pdo, footer_pdo)

                 header_pdo <-  data.frame(input_source = path, table_header = paste(head1_pdo, collapse = " "))

                 assign(x = header.info.name,
                        value = utils::str(header_pdo),
                        envir = parent.frame())

                 }

              return(pdo_df)

              }





