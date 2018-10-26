#' Checks Function Inputs for the Correct Class.
#'
#' This function is supplied as a generic form of all_character, all_numeric,
#' all_logical, and all_list.
#'
#' @param ... Unquoted names of function arguments to check
#' @param class.check One of "character", "numeric", "logical", "list"
#'   specifying what class \code{...} should be.
#'
#' @return Returns an error if the provided parameters do not match the
#'   specified class.
check_inputs <-
  function(class.check,
           ...){

    if(!(class.check %in% c("character",
                            "double",
                            "logical",
                            "list"))){
      stop("class.check must be one of character, double, logical, list")
    }

    class.function <-
      switch (class.check,
        "character" = is.character,
        "double" = is.double,
        "logical" = is.logical,
        "list" = is.list
      )

    parameters_match <-
      all(sapply(list(...),
                 class.function))

    if(!parameters_match){
      stop(paste0("The following arguments must be supplied as ",
                  class.check,
                  ": ",
                  paste(as.character(as.list(match.call(check_inputs))[-c(1:2)]),
                        collapse = ", ")),
           call. = FALSE)
    }
  }

#' @rdname check_inputs
all_character <-
  function(...){
    check_inputs("character",
                 ...)
  }

#' @rdname check_inputs
all_numeric <-
  function(...){
    check_inputs("double",
                 ...)
  }


#' @rdname check_inputs
all_logical <-
  function(...){
    check_inputs("logical",
                 ...)
  }

#' @rdname check_inputs
all_list <-
  function(...){
    check_inputs("list",
                 ...)
  }
