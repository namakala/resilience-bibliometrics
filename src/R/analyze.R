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

genCoupling <- function(bib_aug, ...) {
  #' Generate Coupling Matrix
  #'
  #' Generate a coupling matrix based on a bibliographic data frame
  #'
  #' @param bib_aug An augmented bibliometric data frame, usually the output of
  #' `augmentBib`
  #' @param coupling,network_field Optional parameters to pass on to
  #' `bibliometrix::cocMatrix` as the `Field` parameter. Providing both
  #' `coupling` and `network_field` is necessary to construct a custom adjacency
  #' (square) matrix. See more in the *details* of `mkNetwork`.
  #' @return A tidy data frame containing expanded rows and columns from a
  #' coupling matrix
  require("bibliometrix")

  # Generate a bibliographic network matrix
  net   <- mkNetwork(bib_aug, network_field = "DI", ...)
  index <- rownames(net) %in% bib_aug$DI
  mtx   <- normalizeSimilarity(net, type = "association") %>% {.[index, index]}

  # Convert to data frame containing graph's nodes and edges
  coupling <- mtx %>%
    Matrix::triu() %>% # Convert the lower triangle to zeroes
    as.matrix() %>%
    data.frame(check.names = FALSE) %>%
    dplyr::mutate("from" = colnames(mtx)) %>%
    tidyr::pivot_longer(cols = !from, names_to = "to", values_to = "edge") %>%
    dplyr::filter(edge > 0)

  return(coupling)
}

mapTheme <- function(coupling, bib_aug, cluster) {
  #' Map Bibliographic Theme
  #'
  #' Map the bibliographic theme based on given bibliometric data frame. The
  #' theme comprises four groups: emerging, basic, niche, and motor themes. For
  #' a complete explanation, see `bibliometrix::thematicMap`, this function is
  #' an adaptation of it.
  #'
  #' @param coupling A tidy data frame containing expanded rows and columns
  #' from a coupling matrix
  #' @param bib_aug An augmented bibliometric data frame, usually the output of
  #' `augmentBib`
  #' @param cluster Column name of topic groups in an augmented bibliometric data
  #' frame
  #' @return A thematic map data frame
  require("bibliometrix")

  # Locate entries which prob is greater than its mean
  loc <- with(
    bib_aug,
    switch(
      cluster,
      "topic1" = as.numeric(prob1) %>% {. > mean(., na.rm = TRUE)},
      "topic2" = as.numeric(prob2) %>% {. > mean(., na.rm = TRUE)},
      "topic"  = as.numeric(prob)  %>% {. > mean(., na.rm = TRUE)}
    )
  )

  # Extract node names and grouping clusters
  cluster <- bib_aug %>%
    subset(loc, select = c("DI", cluster, "PY")) %>%
    set_names(c("node", "group", "year")) %>%
    dplyr::mutate("year" = groupYear(year))

  # Convert to data frame containing graph's nodes and edges
  tbl <- coupling %>%
    dplyr::inner_join(cluster, by = c("from" = "node")) %>%
    dplyr::inner_join(cluster, by = c("to"   = "node")) %>%
    dplyr::rename(
      group    = group.x,
      group_to = group.y,
      year     = year.x,
      year_to  = year.y
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
