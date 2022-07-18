
#' @title Plot grPipe Nodes
#'
#' @description
#' save grPipe nodes in \strong{pngfile} path.
#'
#' @param nodes data.frame
#' @param pngfile character
#' @param title character
#' @param plot logical
#' @param showGrid logical
#' @param colSpace numeric
#' @param rowSpace numeric
#'
#' @return No return value.
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
#' grPipe.plot(nodes, tempfile(), showGrid = TRUE)
#' grPipe.plot(nodes, tempfile(), showGrid = FALSE)
#'
#' @export

grPipe.plot = function(nodes, pngfile, title="", plot=TRUE, showGrid=FALSE, colSpace=0.5, rowSpace=0.5) {
  if (showGrid) {
    gridStyle = "filled"
  } else {
    gridStyle = "invis"
  }

  #############################################################################

  # rows
  rows = nodes %>%
    select(id) %>%
    unlist %>%
    as.character
  rows = gsub(pattern = "([A-Z])[0-9]*", replacement = "\\1", x = rows) %>%
    unique %>%
    max
  rows = grep(pattern = rows, x = LETTERS)
  rows = LETTERS[1:rows]

  # cols
  cols = nodes %>%
    select(id) %>%
    unlist %>%
    as.character
  cols = gsub(pattern = "[A-Z]([0-9]*)", replacement = "\\1", x = cols) %>% as.integer
  cols = 1:max(cols)

  #############################################################################

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

  #############################################################################

  # image
  img_nodes = list()
  for (i in 1:nrow(nodes)) {
    if (is.na(nodes[i,"image"])) next

    img_nodes[[nodes[i,"id"]]] = list(
      image = nodes[i,"image"],
      width = 10,
      height = 10
    )
  }

  for (i in names(img_nodes)) {
    # check if image exists
    if (file.exists(img_nodes[[i]][["image"]])) {
      img = image_read(img_nodes[[i]][["image"]])
      img_nodes[[i]][["width"]] = image_info(img)$width
      img_nodes[[i]][["height"]] = image_info(img)$height
    } else {
      stop(paste0("File doesn't exist: ", img_nodes[[i]][["image"]]))
    }
  }

  #############################################################################

  # nodes label
  nodes_label = c()
  aux_label = ""
  for (i in 1:nrow(nodes)) {
    if (!is.na(nodes[i, "text"])) {
      # image
      aux_image = ""
      if (nodes[i,"id"] %in% names(img_nodes)) {
        aux_image = paste0(
          ", width='", (img_nodes[[nodes[i,"id"]]]$width + 2)/72, "'",
          ", height='", (img_nodes[[nodes[i,"id"]]]$height + 2)/72, "'",
          ", labelloc = 'b'"
        )
      }

      if (nodes[i, "text"] == "") nodes[i, "text"] = " "

      # html
      if (grepl(pattern = "^<.*>$", x = nodes[i, "text"])) {
        aux_label = nodes[i, "text"]
      } else {
        aux_label = paste0("\"", nodes[i, "text"], "\"")
      }

      nodes_label = c(
        nodes_label,
        paste0(nodes[i,"id"], " [label=", aux_label, ", ", nodes[i, "attr"], aux_image, "]")
      )
    }
  }
  nodes_label = paste0(nodes_label, collapse = "\n")

  #############################################################################

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

  #############################################################################

  # generate graphviz
  gr = grViz(paste0('
    digraph {
        fontname="Verdana"
        graph [splines=ortho, nodesep="', colSpace, '", ranksep="', rowSpace, '"]
        node [shape=plaintext, fontname="Verdana", style=', gridStyle, ']
        edge [fontname="Verdana"]
        layout=dot
        label="', title, '"
        labelloc = "t"

        // node labels
        ', nodes_label, '

        // node arrows
        ', node_arrow, '

        // hide rank arrows
        edge [weight=1000, style=invis]

        // rank cols (A1, B1, ...)
        ', rank_col, '

        // rank rows (A1, A2, ...)
        ', rank_row, '

    }'))

  # grViz -> xml
  gr = gr %>% export_svg %>% cat %>% capture.output

  # remove text border
  for (i in 1:length(gr)) {
    if (grepl("<text", gr[i])) {
      gr[i] = gsub("<text", "<text style=\"stroke: none\"", gr[i])
    }
  }

  # add images
  aux_id = NA
  aux_points = NA
  aux_width = NA
  aux_height = NA
  aux_x = NA
  aux_y = NA
  for (i in 1:length(gr)) {
    # get id
    if (grepl("<!-- [A-Z0-9]* -->", gr[i])) {
      aux_id = gsub("<!-- ([A-Z0-9]*) .*", "\\1", gr[i])
    }

    # check if id is in the img_nodes
    if (aux_id %in% names(img_nodes)) {
      # image
      aux_image = img_nodes[[aux_id]][["image"]]
      aux_width = img_nodes[[aux_id]][["width"]]
      aux_height = img_nodes[[aux_id]][["height"]]
      # print(gr[i])

      # get polygon points
      if (grepl("<polygon", gr[i])) {
        aux_points = gsub(".*points=\"(.*)\"/>", "\\1", gr[i]) %>% strsplit(" ")
        aux_points = aux_points[[1]]

        # x
        aux_x = as.numeric((aux_points[2] %>% strsplit(","))[[1]][1]) + 1

        # y
        aux_y = as.numeric((aux_points[2] %>% strsplit(","))[[1]][2]) + 1
      }

      # add image
      if (grepl("<text", gr[i])) {
        gr[i] = paste0(
          "<image xlink:href=\"", aux_image, "\" ",
          "width=\"", aux_width, "px\" ",
          "height=\"", aux_height, "px\" ",
          "preserveAspectRatio=\"xMinYMin meet\" ",
          "x=\"", aux_x, "\" ",
          "y=\"", aux_y, "\"/>",
          "\n",
          gr[i]
        )
      }

      if (gr[i] == "</g>") {
        aux_id = NA
      }
    }
  }

  # xml -> svg
  gr = paste0(gr, collapse = "\n")

  # SVG -> magick
  img = image_read(gr %>% charToRaw, density = 200)

  # scale image
  # img = image_scale(img,"2400")

  # image strip
  # img = image_strip(img)

  # save png
  image_write(img, path = pngfile, format = 'png', quality = 100)

  #############################################################################

  # plot image on notebook
  if (plot) {
    plot(img)
  }
}
