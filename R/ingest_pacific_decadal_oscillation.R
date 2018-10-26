#' Ingest Pacific Decadal Oscillation data.
#'
#' \code{ingest_PDO} ingests data from the updated standardized values for the
#' PDO index, derived as the leading PC of monthly SST anomalies in the North
#' Pacific Ocean, poleward of 20N. The monthly mean global average SST anomalies
#' are removed to separate this pattern of variability from any "global warming"
#' signal that may be present in the data.  If you have any questions about this
#' time series, contact Nathan Mantua at: nate.mantua\@noaa.gov \strong{All
#' ingest functions use the source file name as an identifying column to track
#' provenance and relate data and metadata read from files.}
#'
#' @param input.source Character indicating the URI to the HTML representation of the data.
#' @param end.year Four digit integer indicating the last year of data wanted.
#' @param export.header A logical indicating if header information is written to a
#'   separate data frame.
#'
#'
#' @return A data frame.  If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#' @export
#' @examples
#' df_pdo <- ingest_PDO()  # reads in all the data from start date to present
#' df_pdo1 <- ingest_PDO(end.year=2000)  # reads in the data from start date to the year 2000
#'


ingest_PDO <- function(input.source = "http://jisao.washington.edu/pdo/PDO.latest",   # URL to the data
                       end.year = NULL,
                       export.header = TRUE) {

              all_character(input.source)
              all_logical(export.header)
              if(!is.null(end.year)){all_numeric(end.year)}

              pdo_raw <- xml2::read_html(input.source)                       # read in the data
              pdo_pre1 <- rvest::html_node(pdo_raw, "p")             # make data text
              pdo_pre2 <- rvest::html_text(pdo_pre1)

              start_year <- 1900   # define year range
              if(is.null(end.year)){
                 end.year <- as.numeric(format(Sys.Date(), "%Y"))
                }
              count_rows <- as.numeric(end.year+1) - start_year  # get the number of rows

              # skip = 31 was set, but the format of the html must have been changes, it is now skip = 29
              pdo_cols <- scan(textConnection(pdo_pre2), skip=29, nlines=1, what=character())# Get header row
              pdo_df <- utils::read.table(file=textConnection(pdo_pre2), skip=32, stringsAsFactors=F,
                                          sep="", nrow = count_rows,
                                          header=FALSE, col.names=pdo_cols, strip.white=TRUE, fill=TRUE) #
              pdo_df$YEAR <- substr(pdo_df$YEAR, 1, 4)  # removes asterisks from years 2002-present
              pdo_df$input_source <- input.source

              # creates header object
              if(export.header){
                 head_count_rows <- 33+count_rows

                 head_pdo <- scan(textConnection(pdo_pre2), nlines=31, what=character(), sep="\n")
                 footer_pdo <- scan(textConnection(pdo_pre2), skip=head_count_rows, nlines=31,
                                    what=character(), sep="\n")

                 head1_pdo <- c(head_pdo, footer_pdo)

                 table_header = data.frame(header_text = paste(head1_pdo, collapse = " "),
                                           stringsAsFactors = FALSE)

                 export_header(table_header,
                               input.source)

                 }

              return(pdo_df)

              }





