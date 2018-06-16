#' Ingest *sensor/manufacturer/web data source* Data
#'
#' \code{ingest_*data_description*} ingests data from *include information about the data source
#' including manufacturer, sensor name, file extension, version information etc* \strong{All
#' ingest functions use the source file name as an identifying column to track provenance
#' and relate data and metadata read from files. Please check that you have unique file names."}
#'
#' *Any relevant details of parameter arguments and returned values and header information should be
#' specified here.*
#'
#' @param input.source
#' @param header. info A logical indicating if header information is written to a separate data frame
#' @param header.info.name A character indicating the object name for the
#'   metadata data.frame. Defaults to "header_input.source"
#' @param *parmeter.name The parameter description should include accepted class (numeric,
#'      logical, etc.) and refer to the Details section if more explanation is required*
#'
#' @return *Specify what this function returns. Ingest functions should return a data.frame. Provide
#'      any description of the data that may be necessary.* If header.info = TRUE a data.frame is
#'      created in the parent environment of the function.
#'
#' @export
#'
#' @examples
#' *data_description*_file <- system.file("extdata", *Example_File*, package = "ingestr")
#' ingest_*data_description*(file.name = *data_description*_file)

ingest_*data_description* <-
  function(header.info = TRUE,
           header.info.name = NULL,
           *additional parametres*){

    # Check parameter inputs
      *ingestr contains non-exported functions found in internals.R that can be
      used to check the class of values supplied to parameter arguments. These
      functions include all_charcter(), all_logical(), all_numeric(), and
      all_list(). Examples of these functions can be seen in injest_campbell.R
      and injest_pdo.R.

    # Read in data and format to a data frame

      data <- *Read in the data using whatever tools are necessary (delmited, xml,
               etc.) and format to a single dataframe retainng exisiting column names.
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

        # Export header information to the parent environment

        header.info.name <-
              ifelse(is.null(header.info.name),
                     paste0("header_", basename(input.source)),
                     header.info.name)

        assign(x = header.info.name,
               value = header_info,
               envir = parent.frame())

        message(paste("The metadata were returned as the data.frame",
                header.info.name))

      utils::str(header_info)
      }

    return(data)
  }
