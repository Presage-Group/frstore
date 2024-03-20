#' Get Cloud Firebase Project ID
#'
#' @return Character. Firebase Project ID.
#'
#' @examples
#' \dontrun{
#' frstore_project_id()
#' }
frstore_project_id <- function(){
  project_id <- Sys.getenv("FIREBASE_PROJECT_ID")
  if (project_id == "") {
    stop(
      "Firebase Project ID not found.",
      " Please define `FIREBASE_PROJECT_ID` in your .Renviron file.",
      " Restart your R session afterwards.",
      call. = FALSE
    )
  }
  project_id
}
