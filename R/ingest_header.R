#' Ingest header data
#'
#' \code{ingest_header} reads in header information from datasets that were
#' created using \code{ingest_*}. The dataset must have been ingested within the
#' same R session. \strong{All ingest functions use the source file's base name
#' as an identifying column to track provenance and relate data and metadata
#' read from files.}
#'
#' All \code{ingest_*} functions for data files that include header data write
#' that data to a temporary file. This header data can then be loaded and
#' manipulated by the user using \code{ingest_header}.
#'
#' @param input.source Character indicating the source file, must match the
#'   input.source used to originally ingest the data
#'
#' @return This function returns a dataframe containing the header information
#'   for the file. Refer to the help page for \code{ingest_*} for more
#'   information.
#' @export
#'
#' @examples
#' \dontrun{
#' campbell_file <- system.file("example_data", "campbell_scientific_tao5.dat", package = "ingestr")
#' cs_data <- ingest_campbell(input.source = campbell_file)
#' cs_header <- ingest_header(input.source = campbell_file)
#' }
ingest_header <-
  function(input.source){

    all_character("input.source")

    input_source <-
      hash_filename(input.source)

    # Check if the header data has already been loaded this session
    # and load the data.
    if(any(grepl(input_source,
                 list.files(tempdir())))){
      header <-
        readRDS(file.path(tempdir(),
                          input_source))
      message('Header data was loaded from cached results created when ',
              input.source,
              ' was ingested previously in this R session.')
      return(header)
      # This currently just stops the function and displays an errors.
      # Ideally it would have the option to read header data from the specified file,
      # which would require an ingest.function argument to specify the right ingestr
      # to use. Additionally including a 'header.only' argument in the ingestrs would
      # be useful to speed up reading in only header data of large data files.
      } else {
        stop('Header data was not located. Run ingest_*(input.source) to create the header data temporary file.')
    }
  }

#' Sanitize filenames for temporary header files
#'
#' @param filename A file name sting
#'
#' @return Returns a character string with problematic characters replaced by '_'
#'
hash_filename <-
  function(filename){
    # Using httr::sha1_hash because it is already imported by ingestr

    is_url <-
      grepl("^http",
            filename)

    filename <-
      ifelse(is_url,
             gsub("[^[:alnum:]]", "_", filename),
             normalizePath(filename))

    hashed <-
      httr::sha1_hash('ingestr',
                      filename,
                      method = "HMAC-SHA1")
    sanitized <-
      gsub("[^[:alnum:]]", "_", hashed)

    return(sanitized)
  }


#' Export header dataframe to a temporary file
#'
#' @param header.info A dataframe containing file header information
#' @param input.source A character string of the input file
#'
#' @return Returns nothing, saves header dataframe to a temporary file.
#'
export_header <-
  function(header.info,
           input.source){

    header.info$input_source <-
      input.source

    header_path <-
      file.path(tempdir(),
                hash_filename(input.source))

    saveRDS(header.info,
            file = header_path)

    message("Header info for ",
            input.source,
            " has been saved to a temporary file. Run ingest_header('",
            input.source,
            "') to load the header data.")
  }
