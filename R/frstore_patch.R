#' Perform PATCH request to Cloud Firestore database to update data
#'
#' @param document_path Character. The path to a collection or a document.
#' @param id_token Character. Firebase authentication token.
#' @param data List with a specific structure containing data. See [Details].
#'
#' @return Request.
#' @export
#'
#' @details
#' Visit [patch page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/patch)
#' for more details. The `data` must be in this format:
#' \code{
#' list(
#'   fields = list(
#'     field1 = list("<someValue>" = <number>),
#'     field2 = list("<someValue>" = <character>)
#' )
#' )
#' }
#' Where `someValue` can be `arrayValue`, `booleanValue`, `bytesValue`, `doubleValue`,
#' `geoPointValue`, `integerValue`, `mapValue`, `nullValue`, `referenceValue`,
#' `stringValue`, and `timestampValue`. We have tested only `arrayValue`, `doubleValue`,
#' `integerValue`, and `stringValue`.
#'
#' @examples
#' \dontrun{
#' library(frbs)
#' # Sign up via Firebase authentication:
#' frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
#' # Sign in:
#' foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
#' # Suppose there is an existing document at test/firstDoc/firstCollection/doc and we want to update it with new data:
#' data_list <- list(
#'    fields = list(
#'      age = list("integerValue" = 3600),
#'      name = list("stringValue" = "merryyyy")
#'    )
#' )
#' frstore_patch("test/firstDoc/firstCollection/doc", foo$idToken, data_list)
#' }
frstore_patch <- function(document_path, id_token, data){
  tryCatch(
    expr = frstore_req(document_path, id_token) |>
      httr2::req_body_json(data = data) |>
      httr2::req_method("PATCH") |>
      httr2::req_perform(),
    error = frstore_error_handler
  )
}
