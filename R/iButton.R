#' Read iButton Read in iButton data and parameters
#'
#' @param file Character indicating the raw iButton csv file from 1 Wire
#' @param data Logical indicating if the data from the iButton file should be
#'   returned
#' @param metadata Logical indicating if the metadata from the iButton file
#'   should be returned
#'
#' @return If data and metadata are both TRUE then a list of data frames with
#'   items 'data' and 'metadata'. Else a single dataframe of data or metadata
#' @export
read_iButton <- function(file, data = TRUE, metadata = FALSE){

  if(!is.character(file)){
    stop("file must be a string")}
  if(substr(file, nchar(file) - 3, nchar(file)) != ".csv"){
    stop("file should be a csv file")}
  if(!is.logical(data) | !is.logical(metadata)){
    stop("data and metadata must be logicals")}
  if(!data & !metadata){
    stop("Either data or metadata must be TRUE")}

  if(data == TRUE)
  {
    importedData <-
      readr::read_csv(file,
                      skip = 15,
                      col_names = c("sampleTime", "unit", "temperature"))

    valueName <- paste0("temperature_",
                        unique(importedData$unit))

    importedData <-
      dplyr::transmute(importedData,
                       sampleTime = lubridate::mdy_hms(sampleTime,
                                                       truncated = 1),
                       !!valueName := units::set_units(temperature,
                                                       unique(unit),
                                                       mode = "standard"))
    if(metadata == FALSE){
      return(importedData)
    }
  }

  if(metadata == TRUE)
  {
    importedMetadata <-
      readr::read_csv(file,
                      n_max = 13,
                      col_names = FALSE,
                      col_types = readr::cols_only(X1 = "c"))

    importedMetadata <-
      purrr::map2_dfc(.x = stringr::str_extract(importedMetadata[["X1"]],
                                                "^.{1,}(?=(\\?|:)\\s)"),
                      .y = stringr::str_trim(stringr::str_extract(importedMetadata[["X1"]],
                                                                  "(?<=(\\?|:)\\s).{1,}$")),
                      ~tibble::tibble(!!.x := .y))

    importedMetadata <-
      dplyr::rename(.data = importedMetadata,
                    partNumber = `1-Wire/iButton Part Number`,
                    registrationNumber = `1-Wire/iButton Registration Number`,
                    missionActive = `Is Mission Active`,
                    missionStart = `Mission Start`,
                    sampleRate = `Sample Rate`,
                    nMissionSamples = `Number of Mission Samples`,
                    nTotalSamples = `Total Samples`,
                    rollOverEnabled = `Roll Over Enabled`,
                    rollOverOccurred = `Roll Over Occurred`,
                    activeAlarms = `Active Alarms`,
                    nextClockAlarm = `Next Clock Alarm At`,
                    highTempAlarm = `High Temperature Alarm`,
                    lowTempAlarm = `Low Temperature Alarm`)

    importedMetadata <-
      dplyr::mutate(.data = importedMetadata,
                    missionActive = as.logical(missionActive),
                    missionStart = as.POSIXct(stringr::str_replace(missionStart,
                                                                   "[A-Z]{3}",
                                                                   ""),
                                              tz = stringr::str_subset(OlsonNames(),
                                                                       stringr::str_extract(missionStart,
                                                                                            "[A-Z]{3}")),
                                              format = "%a %b %d %T %Y"),
                    sampleRate = units::set_units(as.numeric(stringr::str_extract(sampleRate,
                                                                                  "[0-9]{1,}")),
                                                  stringr::str_extract(sampleRate,
                                                                       "(?<=[0-9]{1,9}\\s)[A-z]{1,}"),
                                                  mode = "standard"),
                    nMissionSamples = as.numeric(nMissionSamples),
                    nTotalSamples = as.numeric(nTotalSamples),
                    rollOverEnabled = as.logical(rollOverEnabled),
                    rollOverOccurred = grepl("not", rollOverOccurred),
                    highTempAlarm = units::set_units(as.numeric(stringr::str_extract(highTempAlarm,
                                                                                     "[0-9]{1,}")),
                                                     stringr::str_extract(highTempAlarm,
                                                                          "[A-Z]{1}$"),
                                                     mode = "standard"),
                    lowTempAlarm = units::set_units(as.numeric(stringr::str_extract(lowTempAlarm,
                                                                                    "[0-9]{1,}")),
                                                    stringr::str_extract(lowTempAlarm,
                                                                         "[A-Z]{1}$"),
                                                    mode = "standard"))

    if(data == FALSE){
      return(importedMetadata)
    }
  }

  importedAll <-
    list("metadata" = importedMetadata,
         "data" = importedData)

  return(importedAll)
}
