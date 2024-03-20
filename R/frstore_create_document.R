#' Perform POST request to Cloud Firestore database to post data
#'
#' @param document_path Character. The path to a collection or a document.
#' @param id_token Character. Firebase authentication token.
#' @param data List with a specific structure. Defaults to [NULL]. See Details.
#'
#' @return Request.
#' @export
#'
#' @details
#' Visit [createDocument page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/createDocument)
#' for more details. The `data` must be in this format:
#' \preformatted{
#' list(
#'   fields = list(
#'     field1 = list("<someValue>" = <number>),
#'     field2 = list("<someValue>" = <character>)
#'   )
#' )
#' }
#' Where `someValue` can be:
#' - `arrayValue`
#' - `booleanValue`
#' - `bytesValue`
#' - `doubleValue`
#' - `geoPointValue`
#' - `integerValue`
#' - `mapValue`
#' - `nullValue`,
#' - `referenceValue`
#' - `stringValue`
#' - `timestampValue`
#'
#' We have tested only `arrayValue`, `doubleValue`,
#' `integerValue`, and `stringValue`.
#'
#' @examples
#' \dontrun{
#' library(frbs)
#' # Sign up via Firebase authentication:
#' frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
#' # Sign in:
#' foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
#' # Create a document without specifying data:
#' frstore_create_document("test/firstDoc", foo$idToken)
#' # Create a document in a subcollection with data:
#' data_list <- list(
#'   fields = list(
#'     age = list("integerValue" = 36),
#'     name = list("stringValue" = "merry")
#'  )
#' )
#' frstore_create_document("test/firstDoc/firstCollection/doc", foo$idToken, data_list)
#' # Create a document with data:
#' frstore_create_document("test/secondDoc", foo$idToken, data_list)
#' }
frstore_create_document <- function(document_path, id_token, data = NULL){
  partial_path <- sub("/[^/]*$", "", document_path)
  document <- tail(strsplit(document_path, "/")[[1]], 1)

  if (is.null(data)){
    tryCatch(
      expr = frstore_req(partial_path, id_token) |>
        httr2::req_url_query(documentId = document) |>
        httr2::req_body_raw("{}", "application/json") |>
        httr2::req_method("POST") |>
        httr2::req_perform(),
      error = frstore_error_handler
    )
  } else {
    tryCatch(
      expr = frstore_req(partial_path, id_token) |>
        httr2::req_url_query(documentId = document) |>
        httr2::req_body_json(data = data) |>
        httr2::req_perform(),
      error = frstore_error_handler
    )
  }
}
