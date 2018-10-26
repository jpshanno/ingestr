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

ingest_*data_description* <-
  function(header.info = TRUE,
           *additional parameters*){

    # Check parameter inputs
      *ingestr contains non-exported functions found in internals.R that can be
      used to check the class of values supplied to parameter arguments. These
      functions include all_charcter(), all_logical(), all_numeric(), and
      all_list(). Examples of these functions can be seen in ingest_campbell.R
      and ingest_pdo.R.

    # Read in data and format to a data frame

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
