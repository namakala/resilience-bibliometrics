# Functions to analyze the bibliometrics data

mkNetwork <- function(bib, short = FALSE, ...) {
  #' Make Network
  #'
  #' Create a square matrix representing a graph object of a bibliometrics
  #' network
  #'
  #' @param bib A bibliometrics data frame
  #' @param coupling,network_field Optional parameters to pass on to
  #' `bibliometrix::cocMatrix` as the `Field` parameter. Providing both
  #' `coupling` and `network_field` is necessary to construct a custom adjacency
  #' (square) matrix. See more in *details*.
  #' @param short A boolean for only including cells which value > 1
  #' @inheritDotParams bibliometrix::biblioNetwork
  #'
  #' @details
  #' Passing on `coupling` and `network_field` parameters are akin to creating a
  #' custom coupling analysis. For example, the results of passing `coupling =
  #' CR` and `network_field = AU` is the same as passing `analysis = coupling` and
  #' `network_field = authors` to `bibliometrix::biblioNetwork`. Similarly, passing
  #' the same field for both `coupling` and `network_field` will give you
  #' co-occurrences network.
  #'
  #' @return A bibliometrics network object
  require("bibliometrix")

  args <- list(...)

  if (hasArg("analysis") & hasArg("network")) {

    net_bib <- biblioNetwork(bib, short = short, ...)

  } else { # Create adjacency matrix based on given fields

    fields <- list("rows" = args$coupling, "cols" = args$network_field) %>%
      lapply(function(field) {
        cocMatrix(bib, Field = field, type = "sparse", sep = ";", short = short)
      })

    net_bib <- with(fields, Matrix::crossprod(rows, cols))
    
    if (nrow(net_bib) != ncol(net_bib)) {
      net_bib %<>% Matrix::crossprod(., .)
    }

  }

  return(net_bib)
}

mapTheme <- function(aug_bib, cluster) {
  #' Map Bibliographic Theme
  #'
  #' Map the bibliographic theme based on given bibliometric data frame. The
  #' theme comprises four groups: emerging, basic, niche, and motor themes. For
  #' a complete explanation, see `bibliometrix::thematicMap`, this function is
  #' an adaptation of it.
  #'
  #' @param bib An augmented bibliometric data frame, usually the output of
  #' `augmentBib`
  #' @param cluster Column name of topic groups in an augmented bibliometric data
  #' frame
  #' @return A thematic map data frame
  require("bibliometrix")

  # Extract node names and grouping clusters
  cluster <- aug_bib %>%
    subset(select = c("DI", cluster, "PY")) %>%
    set_names(c("node", "group", "year")) %>%
    dplyr::mutate(
      "year" = cut(
         year,
         right  = FALSE,
         breaks = c(-Inf, 2000, 2011, Inf),
         labels = c("< 2000", "2000-2010", "> 2010"),
         ordered_result = TRUE
      )
    )

  # Create bibliographic network matrix
  net   <- mkNetwork(aug_bib, coupling = "ID", network_field = "DI")
  index <- rownames(net) %in% cluster$node

  # Normalize the association strength, subset based on indices
  mtx <- normalizeSimilarity(net, type = "association") %>% {.[index, index]}

  # Convert to data frame containing graph's nodes and edges
  tbl <- mtx %>%
    Matrix::triu() %>% # Convert the lower triangle to zeroes
    as.matrix() %>%
    data.frame(check.names = FALSE) %>%
    dplyr::mutate("from" = colnames(mtx)) %>%
    tidyr::pivot_longer(cols = !from, names_to = "to", values_to = "edge") %>%
    dplyr::filter(edge > 0) %>%
    dplyr::left_join(cluster, by = c("from" = "node")) %>%
    dplyr::left_join(cluster, by = c("to"   = "node")) %>%
    dplyr::rename(
      group = group.x,
      group_to   = group.y,
      year  = year.x,
      year_to    = year.y
    )

  # Calculate centrality and density
  tbl_res <- tbl %>%
    dplyr::group_by(year, group) %>%
    dplyr::mutate("ext" = as.numeric(group != group_to)) %>%
    dplyr::summarize(
      "n"          = unique(from) %>% length(),
      "centrality" = sum(edge * ext),
      "density"    = sum({edge * (1 - ext) / n} * 100)
    ) %>%
    dplyr::mutate(
      "rank_central" = rank(centrality),
      "rank_dense"   = rank(density)
    ) %>%
    dplyr::ungroup()

  return(tbl_res)
}
