#' Ingest PP Systems EGM-4 data
#'
#' \code{ingest_egm4} ingests data from *include information about the data source
#' including manufacturer, sensor name, file extension, version information etc* \strong{All
#' ingest functions use the source file name as an identifying column to track provenance
#' and relate data and metadata read from files. Please check that you have unique file names."}
#'
#' *Any relevant details of parameter arguments and returned values and header information should be
#' specified here.*
#'
#' @param input.source Character indicating the PP Systems .dat file from a EGM-4 IRGA
#' @param header.info A logical indicating if header information is written to a separate data frame
#'
#' @return A dataframe. If export.header = TRUE a temporary file is created for
#'   the header data. See \code{\link{ingest_header}} for more information.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' #' egm4_file <- system.file("example_data", "egm4.dat", package = "ingestr")
#' ingest_egm4(input.source = egm4_file)
#' }

ingest_egm4 <-
  function(input.source,
           header.info = TRUE){

    # Check parameter inputs
      all_character(input.source)
      all_logical(header.info)

    # Read in data and format to a data frame

      n_records <-
        length(readLines(input.source)) - 5
        # if(grepl("[Ww]indows", Sys.info()[["sysname"]])){
        #   find_options <-
        #     system("where find",
        #            intern = TRUE)
        #   find_cmd <-
        #     grep("C:\\\\Windows\\\\Sys",
        #          find_options,
        #          value = TRUE)
        #   cmd_string <-
        #     paste0('type "',
        #            input_source,
        #            '" | ',
        #            find_cmd,
        #            ' /c /v ""')
        #   n_records <-
        #     as.numeric(shell(cmd_string, intern = TRUE)) - 5
        # } else {
        #   n_records <-
        #     as.numeric(system(paste0("wc ", input_source, " -l"),
        #                      intern = TRUE)) - 5
        # }

      data <-
        utils::read.table(input.source,
                          header = FALSE,
                          stringsAsFactors = FALSE,
                          sep = "\t",
                          skip = 4,
                          nrows = n_records,
                          col.names = c("plot_number", "record_number", "day", "month",
                                        "hour", "minute", "co2_ppm", "h20_ppm", "temperature_c",
                                        "A", "B", "C", "D", "E", "F", "G", "H", "pressure_mb", "probe_type"))

      colnames(data)[10:17] <-
        switch(as.character(data[["probe_type"]][1]),
               "0" = c("pin1", "pin2", "pin3", "pin4", "pin5", "drop1", "drop2", "drop3"),
               "1" = c("par", "relative_humidity", "soil_temp_c", "drop1", "pin5", "drop2", "drop3", "drop4"),
               "2" = c("par", "relative_humidity", "air_temp_c", "drop1", "drop2", "drop3", "drop4", "drop5"),
               "3" = c("par", "relative_humidity", "air_temp_c", "drop1", "drop2", "drop3", "drop4", "drop5"),
               "4" = c("par", "drop1", "drop2", "drop3", "drop4", "drop5", "drop6", "drop7"),
               "5" = c(paste0("drop", 1:8)),
               "6" = c(paste0("drop", 1:8)),
               "7" = c("par", "relative_humidity_in", "temp_c", "relative_humidity_out", "flow_ml_min", "stomatal_conductance_mmol_m2_s", "drop1", "drop2"),
               "8" = c("par", "relative_humidity", "soil_temp_c", "delta_co2_ppm", "delta_time_sec", "assimilation_gCO2_m2_hr", "drop1", "sign"),
               "9" = c("oxygen", paste0("drop", 1:7)),
               "10" = c("drop1", "relative_humidity", "temp_c", paste0("drop", 1:5)),
               "11" = c("par", "evaporation_mol_m2_s1", "air_temp_c", "delta_co2_ppm", "delta_time_sec", "assimilation_umol_m2_s", "flow_multiplier", "sign"),
               "12" = c("par", "soil_temp_c", "air_temp_c", "delta_co2_ppm", "delta_time_sec", "assimilation_gCO2_m2_hr", "drop1", "sign"))

      # Drop all null columns (varies by probe)
      data <-
        data[, !grepl("drop", colnames(data))]

      # Create +/- values for assimilation
      if(data[["probe_type"]][1]){
        data[, grepl("assimilation", colnames(data))] <-
          data[, grepl("assimilation", colnames(data))] * ifelse(data[["sign"]][1], -1, 1)
        data[, "sign"] <- NULL
      }


    # Add source information to data

      data$input_source <-
                 input.source

    # Read in and format the header data
      if(header.info){
        header_info <-
          data.frame(software_version = sub("^;SoftwareVersion=", "", readLines(input.source, 2)[2]),
                     records_received = as.numeric(sub("^;Received ([0-9]+) record\\(s\\)$", "\\1", readLines(input.source, n_records + 5)[n_records + 5])),
                     probe_number = data[["probe_type"]][1],
                     collection_dates = paste(paste(month.abb[min(data[["month"]])],
                                                    min(data[data[["month"]] == min(data[["month"]]), "day"])),
                                              paste(month.abb[max(data[["month"]])],
                                                    max(data[data[["month"]] == max(data[["month"]]), "day"])),
                                              sep = "--"))

        # Export header information to a temporary file

        export_header(header_info,
                      input.source)

      }

    # Return the dataframe

    return(data)
  }
