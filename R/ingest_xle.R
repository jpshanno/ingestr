#' Ingest Solinst Levellogger data from *.xle files
#'
#' \code{ingest_xle} ingests data from Solinst levellogers that are stored in
#' *.xle format. This is the standard format for data offloaded from Solinst
#' levelloggers and barologgers. \strong{All ingest functions use the source
#' file name as an identifying column to track provenance and relate data and
#' metadata read from files. Please check that you have unique file names."}
#'
#' @param input.source A string representing the file to ingest
#' @param header.info A logical indicating if header information is written to a separate data frame
#' @param collapse.timestamp A logical indicating if a single timestamp should
#'   returned rather than separate date and time columns. Defaults to FALSE,
#'   returning date and time as character columns
#'
#' @return A dataframe. If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#'
#' @export
#'
#' @examples
#' xle_file <- system.file("example_data", "solinst.xle", package = "ingestr")
#' ingest_xle(input.source = xle_file)

ingest_xle <-
  function(input.source,
           header.info = TRUE,
           collapse.timestamp = FALSE){

    # Check parameter inputs
    all_character(input.source)
    all_logical(header.info,
                collapse.timestamp)

    # Read in raw XML
    raw_xml <- xml2::read_xml(input.source)

    # Extract data from XML and convert to a dataframe
    xml_data <-
      xml2::xml_child(raw_xml, "Data")

    # Check for logged data
    if(length(xml2::xml_children(xml_data)) == 0){
      stop(paste0("The file ",
                  input.source,
                  " is apparently empty"))
    }

    data <-
      data.frame(sample_date = xml2::xml_text(xml2::xml_find_all(xml_data, "./Log/Date")),
                 sample_time = xml2::xml_text(xml2::xml_find_all(xml_data, "./Log/Time")),
                 sample_millisecond = xml2::xml_double(xml2::xml_find_all(xml_data, "./Log/ms")),
                 ch1 = xml2::xml_double(xml2::xml_find_all(xml_data, "./Log/ch1")),
                 ch2 = xml2::xml_double(xml2::xml_find_all(xml_data, "./Log/ch2")))

    # Get channel names
    channel_1 <-
      xml2::xml_find_first(raw_xml, "./Ch1_data_header")

    channel_2 <-
      xml2::xml_find_first(raw_xml, "./Ch2_data_header")

    ch1_name <-
      paste(tolower(xml2::xml_text(xml2::xml_child(channel_1, "./Identification"))),
            tolower(xml2::xml_text(xml2::xml_child(channel_1, "./Unit"))),
            sep = "_")

    ch2_name <-
      paste(tolower(xml2::xml_text(xml2::xml_child(channel_2, "./Identification"))),
            tolower(xml2::xml_text(xml2::xml_child(channel_2, "./Unit"))),
            sep = "_")

    # Sanitize names
    ch1_name <-
      gsub("[^[:alnum:]]", "_", ch1_name)

    ch1_name <-
      gsub("__", "_", ch1_name)

    ch2_name <-
      gsub("[^[:alnum:]]", "_", ch2_name)

    ch2_name <-
      gsub("__", "_", ch2_name)

    names(data) <-
      c("sample_date", "sample_time", "sample_millisecond", ch1_name, ch2_name)

    # Convert to timestamp if desired
    if(collapse.timestamp){
      data$sample_timestamp <-
        as.POSIXct(paste(data$sample_date, data$sample_time),
                   format = "%Y/%m/%d %T")
      data$sample_date <-
        NULL
      data$sample_time <-
        NULL
      data <- data[,c("sample_timestamp", "sample_millisecond", ch1_name, ch2_name)]
    }

    # Add source information to data
    data$input_source <-
      input.source

    # Read in and format the header data
      if(header.info){

        # Get relevant information for the header
        header_info <-
          data.frame(instrument_type = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Instrument_type")),
                     model_number = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Model_number")),
                     serial_number = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Serial_number")),
                     firmware = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Firmware")),
                     project_id = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Project_ID")),
                     location = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Location")),
                     lat = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Latitude")),
                     lon = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Longtitude")),
                     sample_rate_seconds = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Sample_rate")),
                     sample_mode = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Sample_mode")),
                     logger_start = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Start_time")),
                     logger_stop = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Stop_time")))

        # Add channel 1 parameters to header info
        ch1_parameter_values <-
          lapply(xml2::xml_attrs(xml2::xml_children(xml2::xml_find_first(raw_xml, "//Ch1_data_header//Parameters"))),
                 paste,
                 collapse = " ")

        if(length(ch1_parameter_values) > 0){
          ch1_parameter_names <-
            paste(tolower(xml2::xml_name(xml2::xml_children(xml2::xml_find_first(raw_xml, "//Ch1_data_header//Parameters")))),
                  ch1_name,
                  sep = "_")

          ch1_parameters <-
            as.data.frame(ch1_parameter_values,
                          col.names = ch1_parameter_names)

          header_info <-
            cbind(header_info, ch1_parameters)
        }

        # Add channel 2 parameters to header info
        ch2_parameter_values <-
          lapply(xml2::xml_attrs(xml2::xml_children(xml2::xml_find_first(raw_xml, "//Ch2_data_header//Parameters"))),
                 paste,
                 collapse = " ")

        if(length(ch2_parameter_values) > 0){
          ch2_parameter_names <-
            paste(tolower(xml2::xml_name(xml2::xml_children(xml2::xml_find_first(raw_xml, "//Ch2_data_header//Parameters")))),
                  ch2_name,
                  sep = "_")

          ch2_parameters <-
            as.data.frame(ch2_parameter_values,
                          col.names = ch2_parameter_names)

          header_info <-
            cbind(header_info, ch2_parameters)

        }

        # Export header information to a temporary file
        export_header(header_info,
                      input.source)

      }

    # Return the dataframe
    return(data)
  }
