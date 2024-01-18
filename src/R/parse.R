# Functions to parse the data

readBib <- function(filepath, ...) {
  #' Read Bibliography
  #'
  #' Read bilbiography file, supporting plain text, csv, or bibtex as
  #' documented in https://www.bibliometrix.org/vignettes/Data-Importing-and-Converting.html
  #'
  #' @param filepath A relative path to access the file, complete with the file
  #' name. It is recommended to have the file named after the database source,
  #' e.g. pubmed.txt or scopus.csv (case insensitive).
  #' @inheritDotParams bibliometrix::convert2df
  #' @return A data frame of `bibliometrixDB` class
  require("bibliometrix")

  # Get filename and extension
  fname <- gsub(x = filepath, ".*/|\\..+", "")
  ext   <- gsub(x = filepath, ".*\\.", "")

  # Stop if fname does not indicate the database
  valid_db <- c("cochrane", "pubmed", "scopus", "wos", "isi", "dimensions")

  msg <- sprintf(
    "Name your file following valid database names: %s",
    paste(valid_db, collapse = ", ")
  )

  if (any(!fname %in% valid_db)) stop(msg)

  # Set data format
  fmt <- dplyr::case_when(
    ext == "txt" ~ "plaintext",
    ext == "csv" ~ "csv",
    ext == "bib" ~ "bibtex"
  )

  if (length(filepath) > 1) {
    bib <- lapply(filepath, readBib, ...)
  } else {
    bib <- convert2df(filepath, dbsource = fname, format = fmt)
  }

  return(bib)
}

mergeBib <- function(bibs, ...) {
  #' Merge Bibliography Data Frames
  #'
  #' Merge a list of bibiography data frames
  #'
  #' @param bibs A list of bibliography data frames
  #' @inheritDotParams base::merge
  #' @return A merged and deduplicated bibliography data frame

  # Get fields from the Web of Science
  wos_field <- names(bibs$wos)

  # Merge bibliography data frames
  bib <- Reduce(\(x, y) merge(x, y, all = TRUE, ...), bibs) %>%
    subset(!{is.na(.$DI) | .$DI == ""}, select = wos_field) %>% # Select only WoS fields
    inset( # Count complete information within an entry
      "n_field",
      value = {
        apply(., 1, \(x) {!is.na(x)} %>% sum())
      }
    ) %>%
    inset( # Standardize the DOI to use upper cases
      "DI", value = stringr::str_to_upper(.$DI)
    )

  # Reorder based on completeness
  bib %<>% {.[order(.$n_field, decreasing = TRUE), ]}

  # Deduplicate the merged data frame
  bib_dedup <- dedup(bib)

  return(bib_dedup)
}

dedup <- function(bib, ...) {
  #' Deduplicate Data Frame
  #'
  #' Deduplicated bibliometric data frame obtained from
  #' `bibliometrix::convert2df`
  #'
  #' @param bib A bibliometric data frame
  #' @inheritDotParams base::duplicated
  #' @return A deduplicated data frame

  # Find duplicates based on DOI and title
  dup_doi   <- duplicated(bib$DI)
  dup_title <- duplicated(bib$TI)
  id        <- dup_doi | dup_title

  # Remove duplicates, prioritize preserving the complete entry
  sub_bib   <- subset(bib, !id)

  return(sub_bib)
}

flatten <- function(tbl, ref, varname, ...) {
  #' Flatten the Data Frame
  #'
  #' Flatten the data frame by grouping and collapsing target column. The data
  #' frame should only contain two columns, as this function is not well tested
  #' on larger data frames.
  #'
  #' @param tbl A data frame
  #' @param ref A character vector signifying the name of reference column for
  #' grouping
  #' @param varname A character vector signifying the name of column to flatten
  #' @inheritDotParams base::paste
  #' @return A tidy data frame

  res <- tbl %>%
    tibble::tibble() %>%
    dplyr::group_by(get(ref)) %>%
    dplyr::summarize(varname = paste(get(varname), ...)) %>%
    set_colnames(c(ref, varname))

  return(res)
}

mergeByDOI <- function(tbls) {
  #' Merge By DOI
  #'
  #' Merge a list of tidy data frames by the column DOI
  #'
  #' @param tbls A list of tidy data frames
  #' @return A tidy data frame with the DOI column
  tbl <- purrr::reduce(
    .f = \(x, y) dplyr::inner_join(x, y, by = "doi", suffix = c("1", "2")),
    .x = tbls
  )

  return(tbl)
}

augToBib <- function(bib, tbl) {
  #' Augment Bibliometric File
  #'
  #' Augment the bibliometric data frame with bagged tokens
  #'
  #' @param bib A bibliometric data frame
  #' @param tbl A tidy data frame with the DOI column
  #' @return An augmented bibliometric data frame

  if (any(class(tbl) == "list")) {
    tbl %<>% mergeByDOI()
  }

  bib_aug <- dplyr::inner_join(bib, tbl, by = c("DI" = "doi"))

  return(bib_aug)
}

augmentBib <- function(bib, topic_doc = NULL, token = NULL) {
  #' Augment Bibliometric File
  #'
  #' Augment the bibliometricc data frame with topics from STM
  #'
  #' @param bib A bibliometric data frame
  #' @param topic_doc Topic per document object, usually the output drawn from
  #' the gamma distribution. Could be a single object or a list of multiple
  #' topic docs.
  #' @param token Bagged token, usually the output of `tokenize`
  #' @return An augmented bibliometric data frame

  if (!is.null(topic_doc)) {
    bib %<>% augToBib(topic_doc)
  }

  if (!is.null(token)) {
    bib %<>% augToBib(token)
  }

  bib_aug <- bib

  return(bib_aug)
}
