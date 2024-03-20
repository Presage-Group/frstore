#' Perform GET request to Cloud Firestore database to get data
#'
#' @param document_path Character. The path to a collection or a document.
#' @param id_token Character. Firebase authentication token.
#' @param fields Character. One or more fields to return. Defaults to [NULL] for all fields.
#'
#' @return A list with requested document(s).
#' @export
#'
#' @details
#' Visit [get page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/get)
#' for more details.
#'
#' @examples
#' \dontrun{
#' # Suppose there is a collection named test with a document named doc.
#' library(frbs)
#' # Sign up via Firebase authentication:
#' frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
#' # Sign in:
#' foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
#' # Get document(s):
#' frstore_get("test", foo$idToken)
#' frstore_get("test/doc", foo$idToken)
#' frstore_get("test/doc", foo$idToken, fields = c("age"))
#' }
frstore_get <- function(document_path, id_token, fields = NULL){
  all_documents <- list()
  page_token <- ""
  while (TRUE) {
    parsed_response <- tryCatch(
      expr = frstore_req(document_path, id_token) |>
        httr2::req_url_query(pageToken = page_token,
                             mask.fieldPaths = fields,
                             .multi = "explode") |>
        httr2::req_perform() |>
        httr2::resp_body_json(),
      error = frstore_error_handler
    )
    # Append documents to the list
    all_documents <- c(all_documents, parsed_response)

    # Check if there are more documents to retrieve
    if (!is.null(parsed_response$nextPageToken)) {
      page_token <- parsed_response$nextPageToken
    } else {
      break  # No more documents to retrieve
    }
  }
  all_documents
}
