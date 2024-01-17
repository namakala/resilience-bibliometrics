# Functions to analyze the bibliometrics data

mkNetwork <- function(bib, ...) {
  #' Make Network
  #'
  #' Create a square matrix representing a graph object of a bibliometrics
  #' network
  #'
  #' @param bib A bibliometrics data frame
  #' @inheritDotParams bibliometrix::biblioNetwork
  #' @return A bibliometrics network object
  require("bibliometrix")

  net_bib <- biblioNetwork(bib, short = TRUE, ...)

  return(net_bib)
}
