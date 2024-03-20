#' Perform DELETE request to Cloud Firestore database to delete data
#'
#' @param document_path Character. The path to a collection or a document.
#' @param id_token Character. Firebase authentication token.
#'
#' @return Request.
#' @export
#'
#' @details
#' Visit [delete page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/delete)
#' for more details.
#'
#' @examples
#' \dontrun{
#' library(frbs)
#' # Sign up via Firebase authentication:
#' frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
#' # Sign in:
#' foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
#' # Suppose there is an existing document at
#' # test/firstDoc/firstCollection/doc
#' # and we want to delete it:
#' frstore_delete("test/firstDoc/firstCollection/doc", foo$idToken)
#' }
frstore_delete <- function(document_path, id_token){
  tryCatch(
    expr = frstore_req(document_path, id_token) |>
      httr2::req_method("DELETE") |>
      httr2::req_perform(),
    error = frstore_error_handler
  )
}
