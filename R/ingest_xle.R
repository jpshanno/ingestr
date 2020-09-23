#' Ingest Solinst Levellogger data from *.xle files
#'
#' \code{ingest_xle} ingests data from Solinst levellogers that are stored in
#' *.xle format. This is the standard format for data offloaded from Solinst
#' levelloggers and barologgers. \strong{All ingest functions use the source
#' file name as an identifying column to track provenance and relate data and
#' metadata read from files. Please check that you have unique file names."}
#'
#' By default Solinst .xle files do not include a timezone, but time are stored
#' in whatever timezone you set the datalogger when launching.
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

    # Get Solinst Levelloger version number because encoding varies based on the
    # software version
    version_line <-
      grep("<Created_by>.*Version",
           readLines(input.source),
           useBytes = TRUE,
           value = TRUE)

    version_number <-
      gsub("[^0-9\\.]",
           "",
           version_line)

    encoding <-
      ifelse(length(version_number) == 1 && version_number >= "4.4.0",
             "UTF-8",
             "iso-8859-1")

    # Read in raw XML
    raw_xml <-
      xml2::read_xml(input.source,
                     encoding = encoding)

    # Extract data from XML and convert to a dataframe
    xml_data <-
      xml2::xml_child(raw_xml, "Data")

    # Check for logged data
    if(length(xml2::xml_children(xml_data)) == 0){
      stop(paste0("The file ",
                  input.source,
                  " is apparently empty"))
    }
    
    # Get variable names for a single record
    column_names <- 
      xml2::xml_child(xml_data) %>% 
      xml2::xml_children() %>% 
      purrr::map_chr(xml2::xml_name)
    
    # Extract into a tibble
    data <- 
      column_names %>% 
      purrr::map_dfc(~sub(pattern = "^", 
                          replacement = "./Log/",
                          x = .x) %>% 
                       xml2::xml_find_all(x = xml_data, 
                                          xpath = .) %>% 
                       xml2::xml_text() %>% 
                       tibble::tibble(.) %>% 
                       setNames(.x)) %>% 
      dplyr::mutate(dplyr::across(-(1:2), as.numeric))
    
    # Get channel names
    
    channel_xpaths <- 
      xml2::xml_children(raw_xml) %>% 
      purrr::map_chr(xml2::xml_name) %>% 
      grep(pattern = "Ch[0-9]{1}_data_header",
           value = TRUE) %>% 
      sub(pattern = "^", 
          replacement = "./")
    
    channel_names <- 
      purrr::map_chr(channel_xpaths,
                 ~paste(xml2::xml_text(xml2::xml_find_first(raw_xml, paste0(.x, "/Identification"))),
                        xml2::xml_text(xml2::xml_find_first(raw_xml, paste0(.x, "/Unit"))),
                        sep = "_") %>% 
                   tolower() %>% 
                   gsub(pattern = "[^A-z0-9]", 
                        replacement = "_") %>% 
                   gsub(pattern = "_{2,}", 
                        replacement = "_"))
    
    # Set Channel Names
    
    names(data) <-
      c("sample_date", "sample_time", "sample_millisecond", channel_names)

    # Convert to timestamp if desired
    if(collapse.timestamp){
      data$sample_timestamp <-
        as.POSIXct(paste(data$sample_date, data$sample_time),
                   format = "%Y/%m/%d %T")
      data$sample_date <-
        NULL
      data$sample_time <-
        NULL
      data <- data[,c("sample_timestamp", "sample_millisecond", channel_names)]
    }

    # Add source information to data
    data$input_source <-
      input.source

    # Read in and format the header data
      if(header.info){

        # Get relevant information for the header
        # These xml2 extractions should be turned into a function or family of
        # functions. 
        # This should be generalized using purrr like the channels were
        header_info <-
          data.frame(instrument_type = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Instrument_type")),
                     model_number = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Model_number")),
                     serial_number = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Serial_number")),
                     firmware = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Firmware")),
                     project_id = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Project_ID")),
                     location = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Location")),
                     lat = xml2::xml_double(xml2::xml_find_first(raw_xml, "//Latitude")),
                     lon = xml2::xml_double(xml2::xml_find_first(raw_xml, "//Longtitude")),
                     sample_rate_seconds = xml2::xml_double(xml2::xml_find_first(raw_xml, "//Sample_rate")) / 100,
                     sample_mode = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Sample_mode")),
                     logger_start = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Start_time")),
                     logger_stop = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Stop_time")),
                     software_version = xml2::xml_text(xml2::xml_find_first(raw_xml, "//Created_by")),
                     download_time =  paste(xml2::xml_text(xml2::xml_find_first(raw_xml, "//File_info/Date")),
                                            xml2::xml_text(xml2::xml_find_first(raw_xml, "//File_info/Time")),
                                            sep = " "),
                     n_records = xml2::xml_double(xml2::xml_find_first(raw_xml, "//Num_log")),
                     stringsAsFactors = FALSE)

        # Sanitize header information
        header_info <-
          lapply(header_info,
                 function(x){
                   ifelse(is.character(x),
                          gsub(" +", " ", x),
                          x)
                 })

        header_info <-
          as.data.frame(header_info,
                        stringsAsFactors = FALSE)

        # Add channel 1 parameters to header info
        channel_metadata <- 
          channel_xpaths %>% 
          purrr::map(~xml2::xml_find_first(raw_xml, .x) %>% 
                       xml2::xml_find_first("./Parameters") %>% 
                       xml2::xml_children())
        
        channel_parameter_values <- 
          purrr::map(channel_metadata,
                     xml2::xml_attrs)
          
        channel_parameter_names <- 
          purrr::map(channel_metadata,
                     xml2::xml_name)
        
        # Remove channels that don't have additional metadata
        has_parameters <- 
          purrr::map_lgl(channel_parameter_names,
                         ~length(.x) != 0)
        
        channel_header_info <- 
          purrr::map2_dfc(channel_parameter_values[has_parameters],
                          channel_parameter_names[has_parameters],
                          ~{
                            value <- .x[[1]][1]
                            unit <- as.character(.x[[1]][2])
                            name <- tolower(paste(.y, unit, sep = "_"))
                            
                            # Convert to numeric if value contains only number and decimals
                            if(!any(grepl("[^0-9\\.]", value))){
                              value <- as.numeric(value)
                            }
                            
                            tibble::tibble(x = value) %>% 
                              setNames(name)
                            })
        
        header_info <- 
          cbind(header_info,
                channel_header_info)

        # Export header information to a temporary file
        export_header(header_info,
                      input.source)

      }

    # Return the dataframe
    return(data)
  }
