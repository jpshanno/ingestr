#' Ingest North Pacific Gyre Oscillation data.
#'
#' \code{ingest_} ingests data from http://www.o3d.org/npgo/ for the North
#' Pacific Gyre Oscillation. \strong{All ingest functions use the source file
#' name as an identifying column to track provenance and relate data and metadata
#' read from files.}
#'
#' @param input.source Character indicating the URI to the HTML representation of the data.
#' @param export.header A logical indicating if header information is written to a
#'   separate data frame.
#'
#'
#' @return A data frame.  If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#' @export
#' @examples
#' df_npgo <- ingest_NPGO()  # reads in all the data
#'


ingest_NPGO <- function(input.source = "http://www.o3d.org/npgo/npgo.php",   # URL of data
                        export.header = TRUE) {

               all_character(input.source)
               all_logical(export.header)

               #npgo_pre <- XML::xpathSApply(XML::xmlParse(httr::content(httr::GET(input.source))),
              #                              "/html/body/pre", XML::xmlValue) # read the data
               if (startsWith(tolower(trimws(input.source)), "http")) {
                 raw_html <- httr::content(httr::GET(input.source))
               } else {
                 raw_html <- xml2::read_html(input.source)
               }
               npgo_pre <- XML::xpathSApply(XML::htmlParse(raw_html),
                                            "//html/body/pre", XML::xmlValue)

               npgo_cols <- scan(textConnection(npgo_pre), skip=25, nlines=1,
                                 what=character())# Get header row
               npgo_cols <- npgo_cols[2:4] # select column names

               npgo_df <- utils::read.csv(file=textConnection(npgo_pre), skip=26, stringsAsFactors=F, sep="",
                                          header=FALSE, col.names=npgo_cols, strip.white=TRUE)
               npgo_df$input_source <- input.source

               # creates header object
               if(export.header){
                  head1_npgo <- scan(textConnection(npgo_pre), nlines=25, what=character(), sep="\n")

                  table_header = data.frame(header_text = paste(head1_npgo, collapse = " "),
                                            stringsAsFactors = FALSE)

                  export_header(table_header,
                                input.source)
                  }

               return(npgo_df)

               }




