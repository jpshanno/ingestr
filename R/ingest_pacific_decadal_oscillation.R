#' Ingest Pacific Decadal Oscillation data
#'
#' @param end_year The last year of data wanted.
#'
#' @return A data frame
#' @export


# Function ---------------------------

ingest_PDO <- function(end_year = NULL) {
              path <- "http://jisao.washington.edu/pdo/PDO.latest"   # URL to the data
              pdo_raw <- xml2::read_html(path)                       # read in the data
              pdo_pre1 <- rvest::html_node(pdo_raw, "p")             # make data text
              pdo_pre2 <- rvest::html_text(pdo_pre1)

              start_year <- 1900   # define year range
              if(is.null(end_year)){
                 end_year <- as.numeric(format(Sys.Date(), "%Y"))
                }
              count_rows <- as.numeric(end_year+1) - start_year  # get the number of rows

              pdo_cols <- scan(textConnection(pdo_pre2), skip=31, nlines=1, what=character())# Get header row
              pdo_df <- read.table(file=textConnection(pdo_pre2), skip=32, stringsAsFactors=F,
                                   sep="", nrow = count_rows,
                                   header=FALSE, col.names=pdo_cols, strip.white=TRUE, fill=TRUE) #
              pdo_df$YEAR <- substr(pdo_df$YEAR, 1, 4)  # removes asterisks from years 2002-present

              }







