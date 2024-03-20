#' Error handler
#'
#' Used in the `tryCatch()` blocks of `frstore_*()` functions
#'
#' @param e Error.
frstore_error_handler <- function(e) {
  resp_err <- httr2::last_response()
  if (!is.null(resp_err)) {
    resp_err <- httr2::resp_body_json(resp_err)$error
    err_list <- list(
      error = list(
        code = resp_err$code,
        message = resp_err$message
      )
    )
    return(err_list)
  }
  stop(conditionMessage(e), call. = FALSE)
}
