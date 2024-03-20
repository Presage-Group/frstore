#' Basic structure of Cloud Firestore request without performing it
#'
#' Other functions add steps to `frstore_req()` and then perform the request.
#'
#' @param document_path Character. The path to a collection or a document.
#' @param id_token Character. Firebase authentication token.
#' @param project_id Character. Firebase project ID. Defaults to [frstore_project_id()].
#' @param base_url Character. Cloud Firestore base url. Defaults to [frstore_base_url()].
#'
#' @return An unperformed request. Contains the full path to a collection (or a document) with request headers.
frstore_req <- function(document_path, id_token, project_id = frstore_project_id(), base_url = frstore_base_url()){
  req <- httr2::request(base_url = base_url) |>
    httr2::req_url_path_append(
      "projects",
      project_id,
      "databases/(default)/documents",
      document_path
    ) |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste("Bearer", id_token)
    )
  req
}
