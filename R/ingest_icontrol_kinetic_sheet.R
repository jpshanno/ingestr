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
#' @param input.source String indicating the output xlsx-file from i-control
#' @param input.sheet Identifier of the sheet to parse. Either the name (strng) or number (1-based) of the sheet.
#' @param header. info A logical indicating if header information is written to a separate data frame
#' @param header.info.name A character indicating the object name for the
#'   metadata data.frame. Defaults to "header_input.source"
#' @return This function returns a dataframe containing the reader data. If
#'   header.info = TRUE a data.frame is created in the parent environment of the
#'   function.
#'
#' @export
#'
#' @examples
#' icontrol_file <- system.file("extdata", "icontrol_384_od_kin.xlsx", package = "ingestr")
#' ingest_icontrol_kinetic_sheet(input.source = icontrol_file)



## Style guide
##     Function names should be in snake_case
##     Function arguments should be written with dots such as function.argument
##     Objects created within functions should be in snake_case
##     All functions should export a data.frame rather than a tibble, matrix, list, etc.
##     Functions that read in data should be in the format ingest_data_description()



ingest_icontrol_kinetic_sheet <- function(input.source,
                                          input.sheet,
                                          header.info = TRUE,
                                          header.info.name = NULL
                                          ){
    
    ## Check parameter inputs
    all_logical(c("header.info"))
    
    all_character(c("input.source",
                    "header.info.name"))
    
    ## Read in data and format to a data frame
    icontrol_data <- icontrol_sheet(ReaderFile=input.source, Sheet=input.sheet)
    data <- as.data.frame(icontrol_data$data)
    
    ## Add source information to data
    data$input_source <- input.source
    data$input_sheet <- input.sheet
    
    ## Read in and format the header data
    if(header.info){
        header_info <- as.data.frame(icontrol_data$header)
        
        ## Export header information to the parent environment
        
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


icontrol_sheet <- function(ReaderFile, Sheet) {
  ## imports a single sheet
  ## example data: 
  RawFile <- readxl::read_excel(ReaderFile, Sheet, col_names=FALSE, col_types="text")
  
  ## Check it is from i-control
  if(! grepl('i-?control', as.character(RawFile[1,1]), ignore.case=TRUE)) {
    stop(sprintf("Sheet %s of File %s is not an i-control file", Sheet, ReaderFile))
  }
  
  ## Find the data
  DataBlock <- which(grepl("^\\D\\d{1,2}",as.character(RawFile[,1,drop=TRUE])))
  ## Warn on non-standard plate formats
  PlateWells <- length(DataBlock)
  message(sprintf("Found %s wells in Sheet %s of File %s", PlateWells, Sheet, ReaderFile))
  if(!PlateWells %in% c(1, 4, 6, 8, 12, 16, 24, 48, 96, 384, 1536))
      warning(sprintf("Found non-standatd well-count: %s", PlateWells))
  ## Check dataBlock is continuous
  if(any(diff(DataBlock)!=1)){
    stop(sprintf("Datablock is not continuous at row(s) %s", paste0(DataBlock[which(diff(DataBlock)!=1)], collapse=' ,')))
  }
  
    
  ## Header is above data separated by empty line
  ## OBS: readxl 0.1.1 does not handle empty rows well: tidyverse/readxl
  if(packageVersion("readxl") < '1.0.0') {
    stop("platereader needs readxl 1.0.0 or newer to parse i-control files")
  }
  EmptyLines <- which(apply(as.matrix(RawFile), 1, function(x) all(is.na(x))))
  HeaderBlock <- seq(1, max(EmptyLines[EmptyLines < min(DataBlock)]))
  HeaderData <- RawFile[setdiff(HeaderBlock,EmptyLines),]

  ## Parse HeaderData
    HeaderDF <- icontrol_header(HeaderData)
    
  
  ## Parse readerData
  if(any(grepl('Kinetic', names(HeaderDF)))) { 
    ReaderDF <- icontrol_kinetic_data(readxl::read_xlsx(path=ReaderFile, sheet=Sheet, skip=DataBlock[1]-4,n_max=length(DataBlock), col_names=FALSE))
    DataType <- 'kinetic'
  } else {
    ReaderDF <- icontrol_endpoint_data(RawFile[DataBlock,])
    DataType <- 'endpoint'
  }
    ## ReaderDF <- plyr::rename(ReaderDF, c(well=sprintf("well_name_%s", PlateWells))) ## eg well_name_384
    ReaderDF$column <- NULL
    
  list(data=ReaderDF, header=HeaderDF)
}

icontrol_header <- function(HeaderData) {
  ## First row is "parameter", the rest is "value"
  ## Some parametres end on ":". Skip that
  HeaderDF <- dplyr::mutate(setNames(HeaderData[,1], 'parameter'), parameter=sub(':$','',parameter))
  HeaderDF$value <- apply(as.matrix(HeaderData[,-1]),1, function(x) paste0(na.omit(x),collapse=' '))
  HeaderTable <- tidyr::spread(HeaderDF, key="parameter", value="value")
  HeaderTable
}



icontrol_kinetic_data <- function(ReadData) {
  EmptyCols <- apply(as.matrix(ReadData),2,function(x) all(is.na(x)))
  ReadData <- ReadData[,!EmptyCols]
  ## well_name_384, kinetic_step, kinetic_second, kinetic_timestamp, kinetic_value (to be renamed), reader_chamber_temperature_C
  cycle_data <- plyr::rename(tidyr::gather(ReadData[c(1,2,3),], key="column",value="parameter_value",-X__1), c(X__1="parameter"))
  read_data <- plyr::rename(tidyr::gather(ReadData[-c(1,2,3),], key="column",value="kinetic_value",-X__1), c(X__1="well"))
  preReaderDF <- merge(cycle_data, read_data, by='column')
  ReaderDF_raw <- tidyr::spread(preReaderDF, key="parameter", value="parameter_value") ## ingestr would return this
##  HeaderNames <- ReadData[c(1,2,3),1]
##  Renamer <- setNames(c("kinetic_step","kinetic_second","reader_chamber_temperature_C"),dplyr::pull(HeaderNames[,1]))
##  ReaderDF <- plyr::rename(dplyr::mutate(ReaderDF_raw, well=normal_wellname(well)), Renamer)
  ##  ReaderDF
  ReaderDF_raw
}

normal_wellname <- function(well) {
  well <- as.character(well)
  pat <- '^(\\D)(\\d{1,2})$'
  if(any(malformed <- !grepl(pat,well))){
    stop(sprintf("Well name number %s: '%s' does not match pattern '%s'", which(malformed),well[malformed],pat))
  }
  sprintf("%s%.2d",sub(pat,'\\1',well), as.integer(sub(pat,'\\2',well)))
}
