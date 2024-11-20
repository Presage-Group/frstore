#' Create path to a firestore collection (event core responses)
#'
#' @param partial_path Initial part of path to the collection.
#' @param collection_id Event core responses collection.
#' @param project_id Firebase project ID.
#'
#' @return Character.
create_path_url <- function(partial_path, collection_id, project_id){
  if (partial_path == collection_id){
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents", ":runQuery")
  } else {
    path_url <- paste0("projects/", project_id, "/databases/(default)/documents/", partial_path, ":runQuery")
  }
  path_url
}



#' Jsonify the selected fields in query
#'
#' @param selected_fields Fields you want to return in response.
#'
#' @return Character.
create_select_clause <- function(selected_fields){
  if (!is.null(selected_fields)) {
    fields_json <- paste(lapply(selected_fields, function(field) {
      glue::glue('{{"fieldPath": "{field}"}}', field = field)
    }), collapse = ", ")

    select_clause <- glue::glue('"select": {{"fields": [{fields_json}]}},', fields_json = fields_json)
  } else {
    select_clause <- ""
  }
  select_clause
}


#' Create a jsonifed query body for a request
#'
#' @param selected_fields Fields you want to return in response.
#' @param filter_by Fields to filter by.
#' @param operation Type of operation.
#' @param value_type Type of value.
#' @param value Value.
#' @param collection_id ID of firestore collection.
#'
#' @return Character.
create_query_body <- function(selected_fields,
                              filter_by,
                              operation,
                              value_type,
                              value,
                              collection_id){

  select_clause <- create_select_clause(selected_fields)

  queryBody <- glue::glue(
    '{
          "structuredQuery": {
            <<select_clause>>
            "where": {
              "fieldFilter": {
                "field": {
                  "fieldPath": "<<filter_by>>"
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
    filter_by  = filter_by,
    operation  = operation,
    value_type = value_type,
    value      = value,
    collection = collection_id,
    select_clause = select_clause,
    .open      = "<<",
    .close     = ">>"
  )
  queryBody
}


#' Create an HTTP request for firestore.
#'
#' @param base_url Base URL.
#' @param path_url URL of the path to a collection.
#' @param id_token Access Token.
#' @param structured_query Query parameters in JSON format.
#'
#' @return Request.
create_request <- function(base_url, path_url, id_token, structured_query){
  httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(path_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste("Bearer", id_token)
    ) |>
    httr2::req_body_raw(structured_query, "application/json")
}





#' Parallel version of frstore_run_query
#'
#' @param query_list List of lists of query parameters for each request.
#' @param id_token Access Token.
#' @param project_id Firebase project ID.
#' @param base_url Base URL.
#'
#' @return List
#' @export
frstore_run_query_parallel <- function(query_list,
                                       id_token,
                                       project_id = frstore_project_id(),
                                       base_url = frstore_base_url()){

  # Collection info.
  collection_paths <- sapply(query_list, function(x){
    x[["collection_path"]]
  })

  partial_paths <- sapply(collection_paths, function(x){
    sub("/[^/]*$", "", x)
  })

  collection_ids <- sapply(collection_paths, function(x){
    utils::tail(strsplit(x, "/")[[1]], 1)
  })

  # Create path URLs
  path_urls <- mapply(
    create_path_url,
    partial_paths,
    collection_ids,
    project_id
  )

  # Create structured queries
  names(collection_ids) <- NULL
  names(path_urls) <- NULL

  query_list <- lapply(seq_along(query_list), function(i) {
    query_list[[i]]$collection_id <- collection_ids[i]
    query_list[[i]]$path_url <- path_urls[i]
    return(query_list[[i]])
  })

  structured_queries <- lapply(
    query_list, function(x){
      create_query_body(
        selected_fields = x$selected_fields,
        filter_by       = x$filter_by,
        operation       = x$operation,
        value_type      = x$value_type,
        value           = x$value,
        collection_id   = x$collection_id
      )
    }
  )

  # Create and perform request
  res <- mapply(function(path, query) {
    create_request(base_url, path, id_token, query)
  }, path_urls, structured_queries, SIMPLIFY = FALSE) |>
    httr2::req_perform_parallel(on_error = "continue", progress = FALSE)
  # httr2::req_perform_sequential(on_error = "continue", progress = FALSE)

  # Get successful responses
  successes <- httr2::resps_successes(res)

  # Get failed responses and corresponding requests
  failures <- httr2::resps_failures(res)
  # failed_requests <- httr2::resps_requests(failures)

  # Process the successful responses
  successful_results <- lapply(successes, function(x) {
    httr2::resp_body_json(x)
  })

  # Process the failed responses
  error_results <- lapply(failures, function(resp) {
    error_info <- httr2::resp_body_json(resp)$error
    list(
      error = list(
        code = error_info$code,
        message = error_info$message
      )
    )
  })

  all_results <- list(
    successful_results = successful_results,
    error_results = error_results
  )

  if (length(all_results$error_results) >= 1){
    message("Some queries resulted in errors. Check the errors by running results$error_results.")
  }

  all_results
}




#' Sequential version of frstore_run_query
#'
#' @param query_list List of lists of query parameters for each request.
#' @param id_token Access Token.
#' @param project_id Firebase project ID.
#' @param base_url Base URL.
#'
#' @return List
#' @export
frstore_run_query_sequential <- function(query_list,
                                         id_token,
                                         project_id = frstore_project_id(),
                                         base_url = frstore_base_url()){

  # Collection info.
  collection_paths <- sapply(query_list, function(x){
    x[["collection_path"]]
  })

  partial_paths <- sapply(collection_paths, function(x){
    sub("/[^/]*$", "", x)
  })

  collection_ids <- sapply(collection_paths, function(x){
    utils::tail(strsplit(x, "/")[[1]], 1)
  })

  # Create path URLs
  path_urls <- mapply(
    create_path_url,
    partial_paths,
    collection_ids,
    project_id
  )

  # Create structured queries
  names(collection_ids) <- NULL
  names(path_urls) <- NULL

  query_list <- lapply(seq_along(query_list), function(i) {
    query_list[[i]]$collection_id <- collection_ids[i]
    query_list[[i]]$path_url <- path_urls[i]
    return(query_list[[i]])
  })

  structured_queries <- lapply(
    query_list, function(x){
      create_query_body(
        selected_fields = x$selected_fields,
        filter_by       = x$filter_by,
        operation       = x$operation,
        value_type      = x$value_type,
        value           = x$value,
        collection_id   = x$collection_id
      )
    }
  )

  # Create and perform request
  res <- mapply(function(path, query) {
    create_request(base_url, path, id_token, query)
  }, path_urls, structured_queries, SIMPLIFY = FALSE) |>
    httr2::req_perform_sequential(on_error = "continue", progress = FALSE)

  # Get successful responses
  successes <- httr2::resps_successes(res)

  # Get failed responses and corresponding requests
  failures <- httr2::resps_failures(res)
  # failed_requests <- httr2::resps_requests(failures)

  # Process the successful responses
  successful_results <- lapply(successes, function(x) {
    httr2::resp_body_json(x)
  })

  # Process the failed responses
  error_results <- lapply(failures, function(resp) {
    error_info <- httr2::resp_body_json(resp)$error
    list(
      error = list(
        code = error_info$code,
        message = error_info$message
      )
    )
  })

  all_results <- list(
    successful_results = successful_results,
    error_results = error_results
  )

  if (length(all_results$error_results) >= 1){
    message("Some queries resulted in errors. Check the errors by running results$error_results.")
  }

  all_results
}
