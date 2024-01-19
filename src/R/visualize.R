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
  #' @return A GGPlot2 object
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

vizTheme <- function(map_bib, topic_label) {
  #' Plot Thematic Map
  #'
  #' Plot the thematic map of modelled topics
  #'
  #' @param map_bib A thematic map data frame, usually the output of `mapTheme`
  #' @param topic_label A labelTopics object, usually the output of `getLabel`
  #' @param A GGPlot2 object
  require("ggplot2")

  mid <- with(map_bib, list("x" = rank_central, "y" = rank_dense) %>% lapply(mean))

  label <- topic_label %>%
    subset(.$weight == "prob", select = -weight) %>%
    dplyr::mutate("token" = gsub(x = token, ";.*", ""))
  
  tbl <- map_bib %>%
    dplyr::inner_join(label, by = c("group" = "topic")) %>%
    dplyr::mutate(
      "group" = as.numeric(group),
      "theme" = dplyr::case_when(
        rank_central < mid$x & rank_dense < mid$y ~ "Emerging",
        rank_central > mid$x & rank_dense < mid$y ~ "Basic",
        rank_central < mid$x & rank_dense > mid$y ~ "Niche",
        rank_central > mid$x & rank_dense > mid$y ~ "Motor"
      )
    ) %>%
    dplyr::group_by(theme, year) %>%
    dplyr::mutate( # Create visual cues based on grouping
      "alpha" = ifelse(theme == "Motor", 0.8, 0.5),
      "size"  = regularize(n) %>% {ifelse(is.na(.), 0, .)} %>% exp(),
      "rank"  = rank(-size, ties.method = "first")
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate( # Adjusting size after ungrouping
      "size" = regularize(n) + size
    )

  plt <- tbl %>%
    ggplot(aes(x = rank_central, y = rank_dense, color = year)) +
    geom_hline(yintercept = mid$y, linetype = 2, color = "grey70") +
    geom_vline(xintercept = mid$x, linetype = 2, color = "grey70") +
    geom_jitter(aes(size = size), alpha = tbl$alpha, width = 0.1, height = 0.1) +
    #geom_point(aes(size = size), alpha = tbl$alpha) +
    ggrepel::geom_text_repel(aes(label = token, size = size), alpha = tbl$alpha) +
    theme(
      axis.ticks = element_blank(),
      axis.text  = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank()
    )

  return(plt)
}
