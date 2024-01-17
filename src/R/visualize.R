# Functions to visualize the data

regularize <- function(x) {
  #' Regularize a Vector
  #'
  #' Regularize a given vector of `x`
  #'
  #' @param x A numeric vector to regularize
  #' @return A regularized numeric vector
  reg <- {x - min(x)} / {max(x) - min(x)}

  return(reg)
}

getGraph <- function(network_bib, n, ...) {
  #' Get Bibliometric Graph
  #'
  #' Get bibliometric graph given the bibliometric network as an input
  #'
  #' @param network_bib A bibliographic network, usually the output of the
  #' `mkNetwork`
  #' @param n The number of vertices to include
  #' @inheritDotParams bibliometrix::networkPlot
  #' @return A tidygraph object for visualization
  require("bibliometrix")

  net <- networkPlot(
    network_bib,
    n           = n,
    size        = 10,
    edgesize    = 3,
    labelsize   = 3,
    size.cex    = TRUE,
    label.cex   = TRUE,
    label.color = TRUE,
    ...
  )

  graph <- net$graph %>%
    tidygraph::as_tbl_graph() %>%
    dplyr::mutate(
      "label"  = stringr::str_to_upper(label),
      "group"  = as.character(community),
      "center" = tidygraph::centrality_betweenness(),
      "node"   = center %>%
        cut(breaks = c(-Inf, median(.), mean(.), Inf)) %>%
        as.numeric() %>%
        exp(),
      "alpha"  = ifelse(node < max(node), 0.5, 0.8)
    )

  return(graph)
}

vizNetwork <- function(...) {
  #' Plot Bibliographic Network
  #'
  #' Plot bibliographic networks from the `biblioNetwork` function
  #'
  #' @param ... Parameters being passed on to `getGraph`
  #' @return A list containing graph object and its clusters
  require("bibliometrix")
  require("ggraph")

  graph <- getGraph(...)
  alpha <- graph %>% igraph::get.vertex.attribute() %>% extract2("alpha")

  plt <- graph %>%
    ggraph("hive", axis = group, sort.by = "degree", normalize = TRUE, offset = pi, axis.pos = c(5, 2, 1, 7)) +
    theme_void() +
    geom_edge_hive(color = "grey70", alpha = 0.4) +
    geom_node_point(aes(size = node, color = group), alpha = alpha) +
    geom_node_text(aes(label = label, size = node / 3), alpha = alpha, repel = TRUE, max.overlaps = Inf) +
    theme(legend.position = "none")
  
  return(plt)
}
