#' Ingest North Pacific Gyre Oscillation data
#'
#' \code{ingest_} ingests data from http://www.o3d.org/npgo/ for the North
#' Pacific Gyre Oscillation. \strong{All ingest functions use the source file
#' name as an identifying column to track provenance and relate data and metadata
#' read from files.}
#'
#' @param path Character indicating the URI to the HTML representation of the data.
#' @param header.info A logical indicating if header information is written to a
#'   separate data frame.
#' @param header.info.name A character indicating the object name for the
#'   metadata data.frame, defaults to "header_npgo".
#'
#'
#' @return A data frame.  If header.info = TRUE a data.frame is created in the
#'   parent environment of the function.
#' @export
#' @examples
#'


# Function ---------------------------

ingest_NPGO <- function(path = "http://www.o3d.org/npgo/npgo.php",   # URL of data
                        header.info = TRUE,
                        header.info.name = "header_npgo") {

               all_character(c("path", "header.info.name"))
               all_logical(c("header.info"))

               npgo_pre <- XML::xpathSApply(XML::xmlParse(httr::content(httr::GET(path))),
                                            "/html/body/pre", XML::xmlValue) # read the data
               npgo_cols <- scan(textConnection(npgo_pre), skip=25, nlines=1,
                                 what=character())# Get header row
               npgo_cols <- npgo_cols[2:4] # select column names

               npgo_df <- utils::read.csv(file=textConnection(npgo_pre), skip=26, stringsAsFactors=F, sep="",
                                          header=FALSE, col.names=npgo_cols, strip.white=TRUE)
               npgo_df$input_source <- path

               # creates header object
               if(header.info){
                  header_npgo <- scan(textConnection(npgo_pre), nlines=25, what=character(), sep="\n")

                  assign(x = header.info.name,
                         value = header_npgo,
                         envir = parent.frame())

                  }

               return(npgo_df)

               }




