#' Ingest Campbell Scientific Logger Data
#'
#' \code{ingest_campbell} ingests data from Campbell Scientific dataloggers that
#' are stored in the TAO5 file format with a .dat exentension. \strong{All
#' ingest functions use the source file name as an identifying column to track
#' provenance and relate data and metadata read from files.}
#'
#' @param file Character indicating the .dat Campbell Scientific File
#' @param units Logical indicating if units specified in the data file should be
#'   appended to the end of the variable names specificed in the data file,
#'   defaults to TRUE
#' @param measurement Logical indicating if measurement type (Avg, Smp,
#'   etc)specified in the data file should be appended to the start of the
#'   variable names specificed in the data file, defaults to TRUE
#' @param header.info A logical indicating if header information is written to a
#'   separate data frame
#' @param header.info.name A character indicating the object name for the
#'   metadata data.frame, defaults to "header_campbell"
#'
#' @return This function returns a dataframe containing logger data. If
#'   header.info = TRUE a data.frame is created in the parent environment of the
#'   function.
#'
#' @export
#'
#' @examples
#' campbell_file <- system.file("extdata", "campbell_scientific_tao5.dat", package = "ingestr")
#' cs_data <- ingest_campbell(file = campbell_file,
#'                            units = TRUE,
#'                            measurement = TRUE,
#'                            header.info = TRUE,
#'                            header.info.name = "header_cs_data")

ingest_campbell <-
  function(file,
           units = TRUE,
           measurement = TRUE,
           header.info = TRUE,
           header.info.name = "header_campbell"){

    column.names <-
        as.data.frame(
          t(
            utils::read.csv(file,
                     skip = 1,
                     nrows = 3,
                     header = F,
                     check.names = FALSE,
                     na.strings = "",
                     stringsAsFactors = F)
          ),
          stringsAsFactors = F
        )

      names(column.names) <-
        c("variable", "units", "type")

      column.names$names <-
        switch(sum(units, measurement) + 1,
               column.names$variable,
               ifelse(rep(units, length(column.names$units)),
                      paste0(column.names$variable,
                             ifelse(is.na(column.names$units),
                                    "",
                                    paste0("_", column.names$units))),
                      paste0(ifelse(is.na(column.names$type),
                                    "",
                                    paste0(column.names$type, "_")),
                             column.names$variable)),
               paste0(ifelse(is.na(column.names$type),
                             "",
                             paste0(column.names$type, "_")),
                      column.names$variable,
                      ifelse(is.na(column.names$units),
                             "",
                             paste0("_", column.names$units))))

      data <- utils::read.csv(file,
                       skip = 4,
                       header = F,
                       stringsAsFactors = F,
                       na.strings = -9999,
                       col.names = column.names$names)

      if(header.info){
        header_info <-
          utils::read.csv(campbell_file,
                          nrow = 1,
                          header = FALSE,
                          col.names = c("file_type",
                                        "logger_name",
                                        "logger_model",
                                        "logger_serial_number",
                                        "logger_os_version",
                                        "logger_program_name",
                                        "logger_program_signature",
                                        "logger_table_name"))
        assign(x = header.info.name,
               value = header_info,
               envir = parent.frame())
      }

      data$input_source <- file
      return(data)
    }
