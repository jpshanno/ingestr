#' Checks Function Inputs for the Correct Class
#'
#' This function is supplied as a generic form of all_character, all_numeric,
#' all_logical, and all_list
#'
#' @param parameters A character vector of function parameters that have
#'   matching classes
#' @param class.check One of "character", "numeric", "logical", "list"
#'   specifying what class \code{parameters} should be
#'
#' @return Returns an error if the provided parameters do not match the
#'   specified class
#'
#' @examples
#'
check_inputs <-
  function(parameters,
           class.check){

    if(!(is.character(parameters) & is.character(class))){
      "parameters must be supplied as a character vector and class.check must be a character."
    }

    if(!(class.check %in% c("character",
                            "numeric",
                            "logical",
                            "list"))){
      stop("class.check must be one of is.character, is.numeric, is.logical, is.list")
    }

    class.function <-
      switch (class.check,
        "character" = is.character,
        "numeric" = is.numeric,
        "logical" = is.logical,
        "list" = is.list
      )

    if(!all(sapply(lapply(parameters, get, envir = parent.frame(2)),
                   function(x){
                     ifelse(is.null(x),
                            TRUE,
                            class.function(x))}))){
      stop(paste0("The following arguments must be supplied as ",
                  class.check,
                  ": ",
                  paste(parameters,
                        collapse = ", ")),
           call. = FALSE)
    }
  }

#' @rdname check_inputs
all_character <-
  function(parameters){
    check_inputs(parameters,
                 "character")
  }

#' @rdname check_inputs
all_numeric <-
  function(parameters){
    check_inputs(parameters,
                 "numeric")
  }

#' @rdname check_inputs
all_logical <-
  function(parameters){
    check_inputs(parameters,
                 "logical")
  }

#' @rdname check_inputs
all_list <-
  function(parameters){
    check_inputs(parameters,
                 "list")
  }
