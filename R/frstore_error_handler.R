#' Error handler
#'
#' Used in the `tryCatch()` blocks of `frstore_*()` functions.
#' Copyright (c) 2024 frbs authors
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
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
