#' Read Campbell Scientific Data Files
#'
#' Read in Campbell Scientific datalogger .dat files
#'
#' @param file Character indicating the .dat Campbell Scientific File
#' @param units Logical indicating if units should be taken from .dat file
#' @param measurement Logical
#'
#' @return A data frame
#' @export

read_campbell <- function(file, units = TRUE, measurement = TRUE){
  column.names <-
    as.data.frame(
      t(
        read.csv(file,
                 skip = 1,
                 nrows = 3,
                 header = F,
                 na.strings = "",
                 stringsAsFactors = F)
      ),
      stringsAsFactors = F
    )

  names(column.names) <-
    c("variable", "units", "type")

  # if(units & measurement){
  # column.names$names <-
  #   paste0(ifelse(is.na(column.names$type),
  #                 "",
  #                 paste0(column.names$type, "_")),
  #          column.names$variable,
  #          ifelse(is.na(column.names$units),
  #                 "",
  #                 paste0("_", column.names$units)))
  # }
  #
  # if(!units & !measurement){
  #   column.names$names <- column.names$variable
  # }

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

  data <- read.csv(file,
                   skip = 4,
                   header = F,
                   stringsAsFactors = F,
                   na.strings = -9999,
                   col.names = column.names$names)

  return(data)
}
