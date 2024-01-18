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
