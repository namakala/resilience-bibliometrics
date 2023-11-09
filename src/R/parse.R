# Functions to parse the data

readBib <- function(filename, ...) {
  #' Read Bibliography
  #'
  #' Read bilbiography file, supporting plain text, csv, or bibtex as
  #' documented in https://www.bibliometrix.org/vignettes/Data-Importing-and-Converting.html
  #'
  #' @param filename A relative path to access the file, complete with the file
  #' name. It is recommended to have the file named after the database source,
  #' e.g. pubmed or scopus (case insensitive).
  #' @inheritDotParams bibliometrix::convert2df
  #' @return A data frame of `bibliometrixDB` class
  require("bibliometrix")
  bib <- convert2df(filename, ...)

  return(bib)
}
