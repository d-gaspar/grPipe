# create new graphviz data.frame
grPipe.create = function() {
  return(
    data.frame(
      id = character(0),
      id_next = character(0),
      text = character(0)
    )
  )
}

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

# plot
grPipe.plot = function(nodes, pngfile, title="", plot=TRUE, showGrid=FALSE) {
  if (showGrid) {
    gridStyle = "filled"
  } else {
    gridStyle = "invis"
  }

  # rows
  rows = nodes %>%
    .[,"id"] %>%
    gsub(pattern = "([A-Z])[0-9]*", replacement = "\\1", x = .) %>%
    unique %>%
    max %>%
    grep(pattern = ., x = LETTERS) %>%
    {LETTERS[1:.]}

  # cols
  cols = nodes %>%
    .[,"id"] %>%
    gsub(pattern = "[A-Z]([0-9]*)", replacement = "\\1", x = .) %>%
    as.integer %>%
    {1:max(.)}

  # rank cols
  rank_col = c()
  for (i in cols) {
    rank_col = c(rank_col, paste0(rows, i, collapse = " -> "))
  }
  rank_col = paste0(rank_col, collapse = "\n")

  # rank rows
  rank_row = c()
  for (i in rows) {
    rank_row = c(rank_row, paste0("rank=same {", paste0(i, cols, collapse = " -> "), "}"))
  }
  rank_row = paste0(rank_row, collapse = "\n")

  # nodes label
  nodes_label = c()
  for (i in 1:nrow(nodes)) {
    nodes_label = c(
      nodes_label,
      paste0(nodes[i,"id"], " [label=\"", nodes[i, "text"], "\", style=filled]")
    )
  }
  nodes_label = paste0(nodes_label, collapse = "\n")

  # node arrows
  node_arrow = c()
  for (i in 1:nrow(nodes)) {
    if (!is.na(nodes[i, "id_next"])) {
      node_arrow = c(
        node_arrow,
        paste0(nodes[i, "id"], " -> ", nodes[i, "id_next"])
      )
    }
  }
  node_arrow = paste0(node_arrow, collapse = "\n")

  # save png
  grViz(paste0('
    digraph {
        fontname="Verdana"
        graph [splines=ortho]
        node [shape=plaintext, fontname="Verdana", style=', gridStyle, ']
        //node [shape=box, fontname="Verdana", style=filled]
        edge [fontname="Verdana"]
        layout=dot
        label="', title, '"
        labelloc = "t"

        ', nodes_label, '

        // arbitrary path on rigid grid
        ', node_arrow, '

        edge [weight=1000 style=dashed color=dimgrey]

        // uncomment to hide the grid
        edge [style=invis]

        ', rank_col, '

        ', rank_row, '

    }'), width = 2400) %>%
    export_svg %>%
    charToRaw %>%
    rsvg_png(pngfile, width = 2400)

  # plot image on notebook
  if (plot) {
    readPNG(pngfile) %>%
      grid.raster(.)
  }
}
