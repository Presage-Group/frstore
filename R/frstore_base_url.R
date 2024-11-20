#' Get the base url for Cloud Firestore
#'
#' @return Character. Base url.
#' @export
#' @examples
#' \dontrun{
#' frstore_base_url()
#' }
frstore_base_url <- function(){
  "https://firestore.googleapis.com/v1beta1"
}
