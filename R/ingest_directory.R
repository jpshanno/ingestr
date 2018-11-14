#' Ingest a directory of uniform files
#'
#' This function reads in all files from a directory using the chosen import
#' function.  Use the 'pattern' argument to specify a set of files, or a
#' single file type. If collapse = TRUE \code{\link[dplyr]{bind}} is used
#' to match column names and bind the imported data into a single object.
#' \strong{All ingest functions use the source file name as an identifying
#' column to track provenance and relate data and metadata read from files.
#' Please check that you have unique file names."}
#'
#' If \code{check.duplicates = "remove"} then only a single set of records will
#' be retained when files have identical contents. This does not provide rowwise
#' checking for duplicates. A separate data.frame specifying the removed
#' input_source, the number of records removed, and the reason for removal.
#'
#' If using an \code{ingest_*} function and \code{header.info.name} must be set to
#' NULL, a character vector of length 1 if \code{collapse = TRUE}, or a named character
#' vector with length equal to the number of files to be ingested if
#' \code{collapse = FALSE}. If \code{header.info.name} is set to NULL then
#' header.info.name will be set to "header_base_directory_name" when
#' \code{collapse = TRUE} or for each file the header information will be stored
#' as "header_filename". If a named character vector is supplied the names
#' should match the file names to be read in and the desired names are stored as
#' the values.
#'
#' @param directory A character vector with the name of the directory that
#'   contains your data files. Defaults to the working directory.
#' @param ingest.function The function to use to read in the files, defaults to
#'   \code{\link[utils]{read.table}} but can take any ingestr or standard import function.
#' @param pattern A character vector providing the pattern to match filenames as
#'   in \code{\link[base]{list.files}}. Defaults to all files "*".
#' @param collapse A logical argument, when true a single object is returned,
#'   when false an object is returned for each file. Defaults to \code{TRUE}.
#' @param recursive A logical argument, when true files are read recursively,
#'   defaults to \code{TRUE}. See \code{\link[base]{list.files}} for more
#'   information..
#' @param use.parallel A logical argument indicating whether the package
#'   \code{\link[parallel]{parallel-package}} should be used.
#' @param check.duplicates A character argument specifying the action that
#'   should be taken if files with duplicate contents are detected. One of
#'   "warn", "remove", or NULL to disable checking. Defaults to "warn".
#' @param ... Additional arguments to pass to the input method
#'
#' @return  When \code{collapse = T} a single object matching the output class
#'   of \code{fun} is returned. When \code{collapse = F} a single object is
#'   returned matching the output class of \code{fun} in the parent environment
#'   of the function. The names of the input sources are used as object names
#'
#' @export

ingest_directory <- function(directory = getwd(),
                             ingest.function = utils::read.csv,
                             pattern = "*",
                             collapse = TRUE,
                             recursive = FALSE,
                             use.parallel = FALSE,
                             check.duplicates = "warn",
                             ...){

  # Check parameter inputs

  all_character(c("check.duplicates", "directory", "pattern"))

  all_logical(c("collapse", "use.parallel", "recursive"))

  function.exists <-
    is.logical(try(is.function(ingest.function), silent = T))

  if(use.parallel && !any(grepl("parallel", .packages(TRUE)))){
    stop("Package 'parallel' must be installed if use.parallel = TRUE")
  }

  if(!function.exists){
    stop("The function specified in ingest.function is not found.
         Check your spelling or ensure that the necessary library is loaded.")
  }

  # Wrap the function in try() to keep a bad file from ending the function.
  import_function <-
    function(x, ...){try(ingest.function(x, ...))}

  # Get file list from directory
  file_list <- list.files(directory,
                         pattern = pattern,
                         recursive = recursive)

  if(any(duplicated(file_list))){
    duplicated_file_names <-
      file_list[duplicated(file_list)]
    stop("The following files have duplicate file names: ",
         duplicated_file_names,
         ". Filenames are used by ingestr to track data provenance and must be unique.")
  }

  names(file_list) <- file_list

  file_count <- length(file_list)

  # Check if header.info.name is provided and meets length requirements.
  if(grepl("header.info.name", names(list(...)))){
    header_info_name_check <-
      ifelse(collapse,
             length(header.info.name) == 1,
             length(header.info.name) == file_count)
    if(!header_info_name_check){
      stop("If header.info.name is provided it must be of length 1 or equal
           to the number of files to be ingested. See Details for more information.")
    }
    if(!identical(sort(names(file_list)),
                  sort(names(header.info.name)))){
      stop("The selected file names do not match the file names supplied in header.info.name")
    }}

  # Read in files
  if(!use.parallel){
    imported_list <-
      lapply(file_list,
             import_function,
             ...)
  } else {
    n_cores <-
      parallel::detectCores(logical = F)
    core_cluster <-
      parallel::makeCluster(n_cores)
    function_arguments <-
      list(cl = core_cluster,
           X = file_list,
           fun = import_function,
           ...)
    parallel::clusterExport(core_cluster,
                            c("file_list", "import_function", "fun", "function_arguments"),
                            envir = environment())
    imported_list <- do.call(parallel::parLapply,
                          function_arguments)
    parallel::stopCluster(cl = core_cluster)
  }

  imported_list <- imported_list[which(vapply(imported_list,
                                              function(x){all(!grepl("try-error",
                                                                     class(x)))},
                                              logical(1)))]

  successful_file_count <- length(imported_list)

  # Collect header information generated by ingest_* functions
  if(length(ls()[grepl("header_.{1,}", ls())]) > 0){
    header_info_names <-
      ls()[grepl("header_.{1,}", ls())]

    header_info_list <-
      lapply(header_info_names,
             get)

    header_info_list <-
      stats::setNames(header_info_list,
               header_info_names)

    header_info_list <-
      header_info_list[sort(names(header_info_list))]

    header.info.name <-
      header.info.name[sort(names(header.info.name))]

    if(!is.null(header.info.name) && length(header.info.name) > 1){
      header_info_list <-
        stats::setNames(header_info_list,
                 header.info.name)

      message("Header information has been returned as individual objects for each ingested file.")

      lapply(seq_len(length(header_info_list)),
             function(x){
               assign(header_info_list[[x]],
                      names(header_info_list)[x],
                      envir = parent.frame(n = 1))
             })

    } else {
      header.info.name <-
        ifelse(is.null(header.info.name),
               paste0("header_",
                      basename(directory)),
               header.info.name)
      assign(dplyr::bind_rows(header_info_list,
                              .id = "input_source"),
             header.info.name,
             envir = parent.frame(n = 1))
    }
  }


  if(successful_file_count != file_count){
    message(file_count - successful_file_count,
            " files were not successfully ingested.")
  }

  if(!is.null(check.duplicates) && any(duplicated(imported_list))){
    duplicated_content_files <-
      names(imported_list)[duplicated(imported_list)]

    if(check.duplicates == "warn"){
      stop("The following files look like they have duplicate contents. Use
           check.duplicates = NULL to suppress this warning or check.duplicated
           = 'remove' to automatically remove duplicate files: ",
           duplicated_content_files)}
    if(check.duplicates == "remove"){
      message("Duplicate file contents were removed from ",
              duplicated_content_files,
              ". See removed_data_",
              basename(directory))
      removed_data <-
        dplyr::bind_rows(lapply(seq_len(length(imported_list)),
                                function(x){
                                  data.frame(input_source = names(imported_list)[x],
                                             data_removed = paste("All", nrow(x), "records from file."),
                                             reason_for_removal = "duplicate file contents",
                                             stringsAsFactors = FALSE)}))

      assign(removed_data,
             paste0("removed_data_", basename(directory)),
             envir = parent.frame(n = 1))
    }
  }

  if(collapse){

    column_names <-
      purrr::map(imported_list,
                 ~names(.x))

    if(!all(purrr::map2_lgl(column_names,
                            column_names[c(2:successful_file_count, 1)],
                            ~identical(.x, .y)))){
      stop("Imported files do not have the same column names.
           If you would still like to combine these datasets then run with collapse =
           FALSE and manually create a single data set from the returned objects.")
    }

    imported_attributes <-
      purrr::map(imported_list,
                 ~purrr::map(.x, ~attributes(.x)))

    template_attributes <-
      imported_attributes[[1]]

    if(!all(purrr::map2_lgl(imported_attributes,
                            imported_attributes[c(2:successful_file_count, 1)],
                            ~identical(.x, .y)))){
      stop("Imported files do not have the same column attributes.
           If you would still like to combine these datasets then run with collapse =
           FALSE and manually create a single data set from the returned objects.")
    }

    importedData <-
      dplyr::bind_rows(imported_list, .id = "input_source")

    lapply(names(importedData)[-1],
           function(x){
             attributes(importedData[[x]]) <<- template_attributes[[x]]
           })

    if(!identical(lapply(importedData[, -1],
                         attributes),
                  template_attributes)){
      message("Unable to restore lost column attributes when the datasets were combined.")
    }

    return(importedData)
  } else {
    lapply(seq_along(imported_list),
           function(x){
             assign(names(imported_list)[x], imported_list[[x]], envir = parent.frame(n = 1))
           })
  }
}
