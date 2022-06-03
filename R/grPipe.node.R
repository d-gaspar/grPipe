
# add or update nodes
grPipe.node = function(nodes, id, id_next, text) {
  # node already exist
  node.exists = (nodes %>% filter(id=={{id}} & id_next=={{id_next}}) %>% nrow) > 0
  if (node.exists) {
    nodes = nodes %>%
      filter(id=={{id}} & id_next=={{id_next}}) %>%
      mutate(text = {{text}})

    # new node
  } else {
    nodes = nodes %>% add_row(
      id = {{id}},
      id_next = {{id_next}},
      text = {{text}}
    )
  }

  return(nodes)
}
