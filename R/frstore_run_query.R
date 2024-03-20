#' Run a query to get specific data from Cloud Firestore.
#'
#' @param collection_path Character. The path to a collection or a subcollection that contains the document(s) you want to query.
#' @param id_token Character. Firebase authentication token.
#' @param field Character. `fieldPath` in `structuredQuery`. See Details.
#' @param operation Character. `op` in `structuredQuery`. See Details.
#' @param value_type Character. Part of `value` in `structuredQuery`. See Details.
#' @param value Character. Part of `value` in `structuredQuery`. See Details.
#' @param project_id Character. Firebase project ID. Defaults to [frstore_project_id()].
#' @param base_url Character. Cloud Firestore base url. Defaults to [frstore_base_url()].
#'
#' @return A list with requested document(s).
#' @importFrom utils tail
#' @export
#'
#' @details
#' Visit [runQuery page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/runQuery)
#' for more details.
#'
#' `structuredQuery` contains these parameters:
#' \code{
#'  {
#'  "structuredQuery": {
#'    "where": {
#'      "fieldFilter": {
#'        "field": {
#'          "fieldPath": "<<field>>"
#'        },
#'        "op": "<<operation>>",
#'        "value": {
#'          "<<value_type>>": "<<value>>"
#'        }
#'      }
#'    },
#'    "from": [
#'      {
#'        "collectionId": "<<collection>>"
#'      }
#'    ]
#'  }
#'  }
#' }
#' Each value in `<<>>` corresponds to a parameter. `op` can be `LESS_THAN`, `LESS_THAN_OR_EQUAL`,
#' `GREATER_THAN`, `GREATER_THAN_OR_EQUAL`, `EQUAL`, `NOT_EQUAL`, `ARRAY_CONTAINS`, `IN`,
#' `ARRAY_CONTAINS_ANY`, and `NOT_IN`.
#'
#' @examples
#' \dontrun{
#' library(frbs)
#' # Sign up via Firebase authentication:
#' frbs_sign_up(email = "<EMAIL>", password = "<PASSWORD>")
#' # Sign in:
#' foo <- frbs_sign_in(email = "<EMAIL>", password = "<PASSWORD>")
#' # Suppose there is an existing subcollection at
#' # test/firstDoc/firstCollection and
#' # we want to get all docs where name matches "merry":
#' frstore_run_query("test/firstDoc/firstCollection",
#'   foo$idToken,
#'   field = "name",
#'   operation = "EQUAL",
#'   value_type = "stringValue",
#'   value = "merry")
#' }
frstore_run_query <- function(collection_path, id_token, field, operation, value_type, value,
                              project_id = frstore_project_id(), base_url = frstore_base_url()) {
  partial_path <- sub("/[^/]*$", "", collection_path)
  collection_id <- utils::tail(strsplit(collection_path, "/")[[1]], 1)

  if (partial_path == collection_id){
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents", ":runQuery")
  } else {
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents/", partial_path, ":runQuery")
  }

  queryBody <- glue::glue(
    '{
        "structuredQuery": {
          "where": {
            "fieldFilter": {
              "field": {
                "fieldPath": "<<field>>"
              },
              "op": "<<operation>>",
              "value": {
                "<<value_type>>": "<<value>>"
              }
            }
          },
          "from": [
            {
              "collectionId": "<<collection>>"
            }
          ]
        }
      }',
    field      = field,
    operation  = operation,
    value_type = value_type,
    value      = value,
    collection = collection_id,
    .open      = "<<",
    .close     = ">>"
  )

  tryCatch(
    expr = httr2::request(base_url = base_url) |>
      httr2::req_url_path_append(path_url) |>
      httr2::req_method("POST") |>
      httr2::req_headers(
        "Content-Type" = "application/json",
        "Authorization" = paste("Bearer", id_token)
      ) |>
      httr2::req_body_raw(queryBody, "application/json") |>
      httr2::req_perform() |>
      httr2::resp_body_json(),
    error = frstore_error_handler
  )
}
