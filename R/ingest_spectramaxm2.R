#' Ingest SpectraMax M2 Plate Reader Data
#'
#' \code{ingest_spectramaxm2} ingests data from raw exports of SpectraMax M2 plate
#' reader data. It will read in text files with any number of plates exported in
#' the PlateFormat. \strong{All ingest functions use the source file name as an
#' identifying column to track provenance and relate data and metadata read from
#' files. Please check that you have unique file names."}
#' Header information is extracted for each plate and stored in a data frame.
#'
#' @param input.source A string representing the file to ingest
#' @param header.info A logical indicating if header information is written to a separate data frame
#'
#' @return A dataframe. If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#'
#' @export
#'
#' @examples
#' *data_description*_file <- system.file("example_data", *Example_File*, package = "ingestr")
#' ingest_*data_description*(input.source = *data_description*_file)

ingest_spectramaxm2 <-
  function(input.source,
           header.info = TRUE){

    # Check parameter inputs
    all_character(input.source)
    all_logical(header.info)

    # Read in raw data
    raw_text <-
      scan(input.source,
           what = character())

    # Check the export format
    exported_format <-
      unique(grep("PlateFormat|TimeFormat",
                  raw_text,
                  value = TRUE))

    if(length(exported_format) > 1){
      stop("The input.source ",
           input.source,
           " contains plates exported in Plate and Time format. Please provide a file with only one export format.")
    }

    if(!match(exported_format, c("PlateFormat", "TimeFormat"))){
      stop("The input.source ",
           input.source,
           " was not exported in plate or time format.")
    }

    if(exported_format == "TimeFormat"){
      stop("TimeFormat exports are currently not supported. Please export your data",
           "in PlateFormat.")
    }

    # Get any note associated with the exported file
    if(grep("~End", raw_text)[1] - grep("Note:", raw_text) != 1){
      file_note <-
        raw_text[grep("Note:", raw_text):grep("~End", raw_text)[1]]
    } else {
      file_note <- NA_character_
      message("No note present in the header of ",
              input.source)
    }

    # Identify plate locations
    plate_end_locations  <-
      grep("^~End$",
           raw_text)[-1] - 1 # Remove the first match (which is for the note)

    plate_name_locations <-
      grep("Plate:",
           raw_text) + 1

    plate_header_ends <-
      grep("Temperature",
           raw_text)

    plate_count <-
      length(plate_end_locations)

    # Extract header information for each plate
    if(header.info){
      header_info <-
        do.call("rbind",
                lapply(seq_len(plate_count),
                       function(x){
                         header_end <- plate_header_ends[x]
                         data.frame(input_source = basename(input.source),
                                    plate_name = raw_text[plate_name_locations[x]],
                                    software_version = raw_text[(header_end - 15)],
                                    read_method = raw_text[(header_end - 13)],
                                    read_type = raw_text[(header_end - 12)],
                                    data_type = raw_text[(header_end - 11)],
                                    header_info_6 = raw_text[(header_end - 10)],
                                    header_info_7 = raw_text[(header_end - 9)],
                                    header_info_8 = raw_text[(header_end - 8)],
                                    wavelength_nm = raw_text[(header_end - 7)],
                                    header_info_10 = raw_text[(header_end - 6)],
                                    header_info_11 = raw_text[(header_end - 5)],
                                    plate_size = raw_text[(header_end - 4)],
                                    header_info_13 = raw_text[(header_end - 3)],
                                    header_info_14 = raw_text[(header_end - 2)],
                                    header_info_15 = raw_text[(header_end - 1)],
                                    stringsAsFactors = FALSE)
                       }))

      # Export header information to a temporary file
      export_header(header_info,
                    input.source)

    }

    # Extract and format the plate data
    data <-
      do.call("rbind",
              lapply(seq_len(plate_count),
                     function(x){
                       plate_name <-
                         raw_text[plate_name_locations[x]]
                       plate_end <-
                         plate_end_locations[x]
                       # These plates could probably be indexed rather than matching the plate name. Plates with the same
                       # name may cause a problem.
                       plate_start <-
                         plate_end - (as.numeric(unique(header_info[header_info$plate_name == plate_name, "plate_size"])) - 1)
                       data.frame(input_source = basename(input.source),
                                  plate_name = plate_name,
                                  well = paste0(rep(LETTERS[1:8], each = 12), 1:12),
                                  read_type = unique(header_info[header_info$plate_name == plate_name, "read_type"]),
                                  value = as.numeric(raw_text[plate_start:plate_end]),
                                  stringsAsFactors = FALSE)
                     }))

    # Add source information to data
    data$input_source <-
      input.source

    # Return the dataframe

    return(data)
  }
