
#' @title create new graphviz data.frame (grPipe nodes)
#'
#' @description
#' if nrow or ncol parameters are equal zero, then the output will be an empty data.frame.
#'
#' @param nrow integer
#' @param ncol integer
#'
#' @author Daniel Gaspar Gonçalves
#'
#' @examples
#' nodes = grPipe.create()
#' nodes = grPipe.create(nrow = 2, ncol = 5)
#'
#' @export

grPipe.create = function(nrow = 0, ncol = 0) {
  if (nrow==0 | ncol==0) {
    nodes = data.frame(
      id = character(0),
      id_next = character(0),
      text = character(0)
    )
  } else {
    nodes = data.frame(
      id = paste0(LETTERS[nrow], ncol),
      id_next = NA,
      text = NA
    )
  }

  return(nodes)
}
