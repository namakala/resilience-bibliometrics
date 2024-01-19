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

getTheme <- function(map_bib, topic_label) {
  #' Plot Thematic Map
  #'
  #' Plot the thematic map of modelled topics
  #'
  #' @param map_bib A thematic map data frame, usually the output of `mapTheme`
  #' @param topic_label A labelTopics object, usually the output of `getLabel`
  #' @return A tidy data frame

  if (any(class(map_bib) == "list") & any(class(topic_label) == "list")) {

    theme <- mapply(
      function(map, topic) {
        getTheme(map, topic)
      },
      map = map_bib,
      topic = topic_label,
      SIMPLIFY = FALSE
    )

    tbl <- lapply(theme, "[[", "tbl") %>% {do.call(rbind, .)}
    mid <- lapply(theme, "[[", "mid") %>% {do.call(rbind, .)} %>%
      colMeans() %>%
      t() %>%
      data.frame()

    theme <- list("mid" = mid, "tbl" = tbl)

    return(theme)
  }

  label <- topic_label %>%
    subset(.$weight == "prob", select = -weight) %>%
    dplyr::mutate("token" = gsub(x = token, ";.*", "") %>% stringr::str_to_upper())
  
  mid <- with(
    map_bib, list("x" = rank_central, "y" = rank_dense) %>% lapply(mean)
  ) %>%
    data.frame()

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
      "size"  = regularize(n) %>% {ifelse(is.na(.), 0, .)} %>% exp() %>% exp(),
      "rank"  = rank(size, ties.method = "first"),
      "alpha" = {ifelse(theme == "Motor", 0.7, 0.5) * rank} %>% regularize() %>% {ifelse(is.na(.), 0, .)}
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate( # Adjusting size after ungrouping
      "size" = regularize(n) + size
    )

  theme <- list("mid" = mid, "tbl" = tbl)

  return(theme)
}

vizTheme <- function(theme) {
  #' Plot Thematic Map
  #'
  #' Plot the thematic map of modelled topics
  #'
  #' @param theme A theme data frame, usually obtained from `getTheme`
  #' @return A GGPlot2 object
  require("ggplot2")

  mid <- theme$mid
  tbl <- theme$tbl

  emerging <- "The role of the environment and society starts to emerge in \nlinking childhood trauma to resilience."
  basic <- "Suicidal ideation and cognitive function after traumatic events \nare the basic theme in resilience research."
  niche <- "The basic of psychological resilience remains as a niche topic. \nVarious studies have been published, yet not highly cited."
  motor <- "Research in resilience is mostly active in elucidating how traumatic \nevent in children affects their mental health."

  modx <- 0.2

  plt <- tbl %>%
    ggplot(aes(x = rank_central, y = rank_dense, color = year)) +
    geom_hline(yintercept = mid$y, linetype = 2, color = "grey70") +
    geom_vline(xintercept = mid$x, linetype = 2, color = "grey70") +
    geom_jitter(aes(size = size), alpha = tbl$alpha * 0.8, width = 0.1, height = 0.1) +
    ggrepel::geom_text_repel(aes(label = token, size = size), alpha = tbl$alpha, show.legend = FALSE) +
    scale_color_manual(breaks = levels(tbl$year), values = c("#81a1c1", "#4c566a", "#bf616a"), name = "Publication Year") +
    guides(size = "none") +
    annotate(
      geom  = "label",
      label = c(emerging, basic, niche, motor),
      x = modx  + rep(c(0, mid$x), 2),
      y = c(mid$y - rep({modx * 1.5}, 2), rep(max(tbl$rank_dense), 2)),
      hjust = "left"
    ) +
    labs(
      title = "Thematic map of most occurring topics extracted from structural topic models",
      x = "A proxy for the number of citations",
      y = "A proxy for the number of publications"
    ) +
    theme_minimal() +
    theme(
      axis.ticks = element_blank(),
      axis.text  = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank()
    )

  return(plt)
}

