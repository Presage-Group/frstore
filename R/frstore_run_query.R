#' Run a query to get specific data from Cloud Firestore.
#'
#' @param collection_path Character. The path to a collection or a subcollection that contains the document(s) you want to query.
#' @param id_token Character. Firebase authentication token.
#' @param filters List. Contains a list for each filter that includes filter type, field, operation, and value.
#' @param selected_fields Character. Part of `select` in `structuredQuery`. See Details.
#' @param project_id Character. Firebase project ID. Defaults to [frstore_project_id()].
#' @param base_url Character. Cloud Firestore base url. Defaults to [frstore_base_url()].
#'
#' @return A list with requested document(s).
#' @importFrom utils tail
#' @importFrom glue glue
#' @export
#'
#' @details
#' Visit [runQuery page of Firestore REST API docs](https://cloud.google.com/firestore/docs/reference/rest/v1beta1/projects.databases.documents/runQuery)
#' for more details.
#'
#' `structuredQuery` contains these parameters:
#' \preformatted{
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
#'   }
#'  }
#' }
#' Each value in `<<>>` corresponds to a parameter. `op` can be `LESS_THAN`, `LESS_THAN_OR_EQUAL`,
#' `GREATER_THAN`, `GREATER_THAN_OR_EQUAL`, `EQUAL`, `NOT_EQUAL`, `ARRAY_CONTAINS`, `IN`,
#' `ARRAY_CONTAINS_ANY`, and `NOT_IN`.
frstore_run_query <- function(collection_path, id_token, filters,
                              selected_fields = NULL,
                              project_id = frstore_project_id(), base_url = frstore_base_url()) {
  partial_path <- sub("/[^/]*$", "", collection_path)
  collection_id <- utils::tail(strsplit(collection_path, "/")[[1]], 1)

  if (partial_path == collection_id) {
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents", ":runQuery")
  } else {
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents/", partial_path, ":runQuery")
  }

  # Constructing the select clause if selected_fields is provided
  if (!is.null(selected_fields)) {
    fields_json <- paste(lapply(selected_fields, function(field) {
      glue::glue('{{"fieldPath": "{field}"}}', field = field)
    }), collapse = ", ")

    select_clause <- glue::glue('"select": {{"fields": [{fields_json}]}},', fields_json = fields_json)
  } else {
    select_clause <- ""
  }

  # Construct filters JSON
  filters_json <- paste(lapply(filters, function(filter) {
    if (filter$type == "fieldFilter") {
      return(glue::glue('{
        "fieldFilter": {
          "field": {"fieldPath": "<<filter$field>>"},
          "op": "<<filter$op>>",
          "value": {"<<filter$value_type>>": "<<filter$value>>"}
        }
      }', .open = "<<", .close = ">>"))
    } else if (filter$type == "unaryFilter") {
      return(glue::glue('{
        "unaryFilter": {
          "field": {"fieldPath": "<<filter$field>>"},
          "op": "<<filter$op>>"
        }
      }', .open = "<<", .close = ">>"))
    }
  }), collapse = ", ")

  if (length(filters) == 1) {
    filters_clause <- glue::glue('"where": <<filters_json>>,', filters_json = filters_json, .open = "<<", .close = ">>")
  } else {
    filters_clause <- glue::glue('"where": {"compositeFilter": {"op": "AND", "filters": [<<filters_json>>]}},', filters_json = filters_json, .open = "<<", .close = ">>")
  }

  queryBody <- glue::glue(
    '{
      "structuredQuery": {
        <<select_clause>>
        <<filters_clause>>
        "from": [
          {
            "collectionId": "<<collection>>"
          }
        ]
      }
    }',
    collection = collection_id,
    select_clause = select_clause,
    filters_clause = filters_clause,
    .open = "<<",
    .close = ">>"
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
