
# create new graphviz data.frame
grPipe.create = function(nrow = 0, ncol = 0) {
  if (nrow==0 | ncol==0) {
    nodes = data.frame(
      id = character(0),
      id_next = character(0),
      text = character(0)
    )
  } else {
    nodes = data.frame(
      id = paste0(LETTERS[ncol], nrow),
      id_next = NA,
      text = NA
    )
  }

  return(nodes)
}
