#' Ingest Delta-T HH2 Logger PR2 Probe Data
#'
#' \code{ingest_DeltaT_HH2_PR2} ingests data from the Delta-T HH2 Moisture Meter with the 
#' ML series sensor and PR2 Profile Probe. This is used to collect soil moisture content 
#' and depth profiles.  \strong{All ingest functions use the source file name as an identifying 
#' column to track provenance and relate data and metadata read from files. Please check 
#' that you have unique file names."}
#'
#' *Any relevant details of parameter arguments and returned values and header information should be
#' specified here.*
#'
#' @param input.source 
#' @param header. info A logical indicating if header information is written to a separate data frame
#' @param *parmeter.name The parameter description should include accepted class (numeric,
#'      logical, etc.) and refer to the Details section if more explanation is required*
#'
#' @return A dataframe. If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#'
#' @export
#'
#' @examples
#' *data_description*_file <- system.file("extdata", *Example_File*, package = "ingestr")
#' ingest_*data_description*(file.name = *data_description*_file)

ingest_DeltaT_HH2_PR2 <- function(input.source,
                                  header.info = TRUE,
                                  export.header = TRUE){

                         # Check parameter inputs
                         all_character(input.source)
                         all_logical(export.header)

                         # Read in data and format to a data frame
                         dat1_raw <- readLines(input.source)
                         dat1_h1 <- !(stringr::str_detect(dat1_raw, ""))
                         
                         nvec <- length(dat1_raw)
                         breaks <- which(! nzchar(dat1_raw))
                         nbreaks <- length(breaks)
                         if (breaks[nbreaks] < nvec) {
  breaks <- c(breaks, nvec + 1L)
  nbreaks <- nbreaks + 1L
}
    
                         if (nbreaks > 0L) {
  dat1 <- mapply(function(a,b) paste(dat1_raw[a:b], collapse = " "),
                   c(1L, 1L + breaks[-nbreaks]),
                   breaks - 1L)
                         }                     
                         
                         dat1[1]
                         dat1[3]
                        
                         dat1_raw %>%
      tidyr::separate(into = paste0('dat1_raw', 1:4), sep = dat1_h1) %>% 
      unlist(., use.names = FALSE)
                         
                         #################

                          dat1 <- utils::read.csv(text = dat1_raw,  
                                                 stringsAsFactors=F, header=FALSE, strip.white=TRUE)
                         ###################
          
                         dat1 <- utils::read.csv(input.source, 
                                                 stringsAsFactors=F, header=FALSE, strip.white=TRUE)
                         
                         dat1c <- unpivotr::as_cells(dat1)
                         dat1_corners <- dplyr::filter(dat1c, 
                                                       chr %in% c("Table >>", "Device >>"))
                         dat1_p <- unpivotr::partition(dat1c, dat1_corners)
                         dat1_b <- dat1_p %>% 
                                   behead("NNW", subject) %>% 
                                  
                           
   
      
      read.Lines
      unpivotr
    

      data <- *Read in the data using whatever tools are necessary (delmited, xml, httr
               etc.) and format to a single dataframe retaining exisiting column names.
               Any standard columns provided by the manufacturer (e.g. TIMESTAMP) should
               be retained and converted to the correct format (e.g. POSIXct) if it is a
               standard feature of the datafile.*

    # Add source information to data

      data$input_source <-
                 *file.name/path as a charcter. Should be an argument in the injest function*

    # Read in and format the header data
      if(header.info){
        header_info <- *Read in the header data using whatever tools are necessary
                        (delmited, xml, etc.) and format to a single dataframe
                        using supplied manufacturer names where possible.*

        # Export header information to a temporary file

        export_header(header_info,
                      input.source)

      }

    # Return the dataframe

    return(data)
  }