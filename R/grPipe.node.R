
#' @title Add or Update grPipe Nodes
#'
#' @description
#' add a new node if it doesn't exist or update an existing one.
#'
#' @param nodes data.frame
#' @param id character
#' @param id_next character
#' @param text character
#' @param attr character
#'
#' @return Returns a data.frame with 4 columns (id, id_next, text and attr) where:
#' \itemize{
#'     \item If \strong{id} and \strong{id_next} already exist in the data.frame \strong{nodes}, then return the data.frame \strong{nodes} with the value \strong{text} updated;
#'     \item Otherwise, add a row in the data.frame \strong{nodes} with the values passed (\strong{id}, \strong{id_next} and \strong{text}) and then return the data.frame \strong{nodes}.
#' }
#'
#' @author Daniel Gaspar Gonçalves
#'
#' @examples
#' nodes = grPipe.create(2,5)
#' nodes = grPipe.node(nodes, "A1",  "A2",  "input")
#' nodes = grPipe.node(nodes, "A2",  "B2",  "step 1")
#' nodes = grPipe.node(nodes, "B2",  "B3",  "step 2")
#' nodes = grPipe.node(nodes, "B3",  "B4",  "step 3")
#' nodes = grPipe.node(nodes, "B4",  "A4",  "step 4")
#' nodes = grPipe.node(nodes, "A4",  "A5",  "step 5")
#' nodes = grPipe.node(nodes, "A5",  NA,  "output")
#'
#' @export

grPipe.node = function(nodes, id, id_next, text, attr = "style=filled, shape=box, fillcolor='#d3d3d3', color='#d3d3d3', margin='0.2,0'") {
  # node already exist
  node.exists = (nodes %>% filter(id=={{id}} & id_next=={{id_next}}) %>% nrow) > 0
  if (node.exists) {
    nodes_aux = nodes %>%
      filter(id=={{id}} & id_next=={{id_next}}) %>%
      mutate(
        text = {{text}},
        attr = {{attr}}
      )
    nodes = nodes %>%
      filter(!(id=={{id}} & id_next=={{id_next}})) %>%
      bind_rows(nodes_aux)

    # new node
  } else {
    nodes = nodes %>% add_row(
      id = {{id}},
      id_next = {{id_next}},
      text = {{text}},
      attr = {{attr}}
    )
  }

  return(nodes)
}
