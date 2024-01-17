# Functions to perform text mining

tokenize <- function(bib, wordlist = NULL, ...) {
  #' Make Text Corpus
  #'
  #' Create a text corpus from the abstracts of extracted query results. The
  #' text is first tokenized into words, then stop words are removed.
  #'
  #' @param bib A bibliography data frame from exported query results
  #' @param wordlist Additional list of stop word to exclude
  #' @param ... Parameters to pass on to `tokenizeNgrams`
  #' @return A data frame containing DOI and tokenized abstract
  require("tidytext")

  abstract <- bib %>%
    subset(select = c(DI, AB)) %>%
    set_names(c("doi", "abstract")) %>%
    tibble::tibble()

  if (!is.null(wordlist)) {
    wordlist %<>% readLines()
    stopword  <-  c(wordlist, stop_words$word)
  } else {
    stopword  <-  stop_words$word
  }

  token <- tokenizeNgrams(abstract, stopword = stopword, ...)

  return(token)
}

tokenizeNgrams <- function(abstract, n, stopword = NULL) {
  #' Tokenize N-Grams
  #'
  #' A wrapper function for `tidytext::unnest_token` to formalize the switching
  #' mechanism of the `tokenize` function. This function takes any value of n >
  #' 0 and creates the logic for filtering the tokens.
  #'
  #' @param abstract A data frame containing DOI and abstract
  #' @param n The number of n-grams token to be generated
  #' @param stopword A character vector signifying which stop words to exclude
  #' @return A data frame containing DOI and tokenized words
  require("tidytext")

  token <- abstract %>%
    unnest_tokens(input = "abstract", output = "word", token = "ngrams", n = n) %>%
    subset(!is.na(.$word))

  tokens <- token %>%
    tidyr::separate(word, paste0("word", 1:n), sep = " ")

  if (!is.null(stopword)) {
    filter <- sprintf("tokens$word%s %%in%% stopword", 1:n) %>%
      paste(collapse = " | ") %>%
      {eval(parse(text = .))}
  } else {
    filter <- FALSE # Will return all entries if no stopword is used
  }

  token_filtered <- tokens %>% subset(!filter)

  combined_token <- paste0("token_filtered$word", 1:n) %>%
    paste(collapse = ", ") %>%
    {sprintf("paste(%s)", .)} %>%
    {eval(parse(text = .))}

  token_clean <- token_filtered %>%
    inset2("word", value = combined_token) %>%
    subset(select = c("doi", "word"))

  return(token_clean)

}

countToken <- function(token, summarize = TRUE) {
  #' Count Tokenize Words
  #'
  #' Count words from tokenized data frame. This function will taken output
  #' from `tokenize` function as an input.
  #'
  #' @param token A data frame containing DOI and tokenized words
  #' @param summarize Whether to return a summary across all abstracts (`TRUE`) or count
  #' the token per abstract (`FALSE`)
  #' @return A data frame of token counts

  if (summarize) {
    token_count <- token %>%
      dplyr::count(word, sort = TRUE)
  } else {
    token_count <- token %>%
      dplyr::count(doi, word, sort = TRUE)
  }

  return(token_count)
}

getTokenStat <- function(token, summarize = TRUE) {
  #' Calculate Token Statistics
  #'
  #' Calculate the TF-IDF statistics from the token counts. TF-IDF is the
  #' multiplication between term frequency (TF) and inverse document frequency
  #' (IDF), which signifies the importance of a particular token within and
  #' across documents. IDF decreases the weight of commonly-used words
  #' and increases the weight of not commonly-used words.
  #'
  #' @param token A data frame containing DOI and tokenized words
  #' @param summarize Whether to return a summary across all token (`TRUE`) or
  #' provide TF/IDF value per abstract (`FALSE`)
  #' @return A data frame containing TF, IDF, and TF-IDF values
  token_stat <- token %>%
    countToken(summarize = FALSE) %>%
    tidytext::bind_tf_idf(term = "word", document = "doi", n = "n")

  if (summarize) {
    token_stat %<>%
      dplyr::group_by(word) %>%
      dplyr::summarize(
        "n"      = sum(n),
        "tf"     = mean(tf, na.rm = TRUE),
        "tf_idf" = mean(tf_idf, na.rm = TRUE)
      )
  }

  token_stat %<>% {.[order(.$n, .$tf_idf, decreasing = TRUE), ]}

  return(token_stat)
}

mkDocMatrix <- function(token, bib = NULL) {
  #' Make Document Matrix
  #'
  #' Create a document feature matrix (DFM) natively supported by the
  #' `quanteda` package. The DFM object is intended to use for topic modelling
  #' using the `stm` package.
  #'
  #' @param token A data frame containing DOI and tokenized abstract
  #' @param bib A bibliography data frame from exported query results
  #' @return A document feature matrix object for topic modelling
  tbl <- countToken(token, summarize = FALSE)
  doi <- unique(tbl$doi)
  dfm <- tidytext::cast_dfm(tbl, document = "doi", term = "word", value = "n")

  if (!is.null(bib)) {
    bib %<>% subset(.$DI %in% doi)
    quanteda::meta(dfm, "doi")      <- bib$DI
    quanteda::meta(dfm, "title")    <- bib$TI
    quanteda::meta(dfm, "keywords") <- bib$DE
    quanteda::meta(dfm, "source")   <- bib$SO
  }

  return(dfm)
}

genTopic <- function(dfm, ...) {
  #' Generate Topics
  #'
  #' Generate topics using unsupervised learning approach with structural topic
  #' model (STM). STM is preferred to LSA, PLSA, or CTM due to its speed
  #' and support of meta data uses.
  #'
  #' @param dfm A document-feature matrix object for topic modelling, usually
  #' the output of `mkDocMatrix` or `tidytext::cast_dfm`
  #' @return A fitted STM object
  doc  <- quanteda::convert(dfm, to = "stm")
  doi  <- doc$documents %>% names()
  meta <- quanteda::meta(dfm) %>% data.frame()

  mod  <- tryCatch(
    stm::stm(
      documents = doc$documents,
      vocab     = doc$vocab,
      data      = meta,
      init.type = "Spectral",
      ...
    ), error = function(e) {
      message(e)
      stm::stm(
        documents = doc$documents,
        vocab     = doc$vocab,
        data      = meta,
        init.type = "LDA",
        ...
      )
    }
  )

  mod$doi <- doi

  return(mod)
}

getTopic <- function(mod, type = "beta", truncate = TRUE, n = 1e2) {
  #' Get Generated Topics
  #'
  #' Extract generated topics from the model. This function takes STM model as
  #' an input. If the model is generatd using `genTopic` function, it should
  #' have one additional field: `doi`, indicating the DOI number of the
  #' included documents. This DOI number will be assigned when extracting the
  #' gamma values.
  #'
  #' @param mod An STM object, usually the output of `genTopic` function
  #' @param type A character object signifying the type of matrix to export, currently supporting "beta" and
  #' "gamma"
  #' @param truncate Whether to return only the truncated version, i.e. by
  #' selecting `n` most occuring ones
  #' @param n The number of subset to select in a truncated data
  #' @return A data frame of topic and its probability either in beta or gamma
  #' distribution, depends on the `type` parameter
  require("dplyr")

  if (type == "beta") {

    res <- tidytext:::tidy_stm_beta(mod, log = FALSE) %>%
      set_names(c("topic", "term", "prob"))

    sub_res <- res %>%
      group_by(topic) %>%
      slice_max(prob, n = n) %>%
      ungroup() %>%
      arrange(topic, -prob)

  } else if (type == "gamma") {

    doi <- NULL
    if (with(mod, exists("doi"))) {
      doi <- mod$doi
    }

    res <- tidytext:::tidy_stm_gamma(mod, log = FALSE, document_names = doi) %>%
      set_names(c("doi", "topic", "prob"))

    sub_res <- res %>%
      group_by(doi) %>%
      slice_max(prob, n = n) %>%
      ungroup() %>%
      arrange(doi, -prob)

  } else {

    stop("Type is not supported")

  }

  sub_res %<>% inset("ntopic", value = max(.$topic))

  if (truncate) {
    return(sub_res)
  }

  return(res)
}

evalTopic <- function(stm, dfm) {
  #' Evaluate Topic Model
  #'
  #' Evaluate the generated topic from the stuctural topic model using the
  #' document-frequency matrix as a reference
  #'
  #' @param stm A STM model, usually an output of `stm::stm` or `genTopic`
  #' @param dfm A document-frequency matrix, usually an output of `mkDocMatrix`
  #' @return A measure of semantic coherence and eclusivity as provided by
  #' `stm::semanticCoherenc` and `stm::exclusivity`

  res <- tibble::tibble(
    "coh" = stm::semanticCoherence(model = stm, documents = dfm),
    "exc" = stm::exclusivity(model = stm)
  )

  return(res)

}

selTopicParam <- function(eval_summary) {
  #' Select Topic Param
  #'
  #' Select topic parameters that maximize both semantic coherence and
  #' exclusivity (FREX)
  #'
  #' @param eval_summary The summary obtained by finding the mean value for
  #' each column from the output of `evalTopic`
  #' @return A numeric value indicating the branch with optimum params
  tbl <- eval_summary

  tbl %<>% lapply(function(varname) {
    varname %>% {{. - min(.)} / {max(.) - min(.)}}
  }) %>%
    data.frame()

  argmax <- rowSums(tbl) %>% {which(. == max(.))}

  return(argmax)
}

getLabel <- function(stm, summarize = FALSE, ...) {
  #' Get Label
  #'
  #' Get label associated with a topic from an STM model
  #'
  #' @param stm A fitted STM object
  #' @param summarize Boolean to indicate whether to summarize all labels as
  #' one data frame or not
  #' @inheritDotParams stm::labelTopics
  #' @return A labelTopics object (list)
  topic_label <- stm::labelTopics(stm, n = 10, ...) %>%
    extract(c(1, 4, 3, 2)) %>% # Remove unnecessary field, reorder the list
    data.frame() %>%
    t() %>%
    data.frame() %>%
    set_colnames(1:ncol(.))

  metrics <- gsub(x = rownames(topic_label), "\\..*", "")

  res <- topic_label %>% lapply(function(label) {
      data.frame("weight" = metrics, "token" = label) %>%
        dplyr::group_by(weight) %>%
        dplyr::summarise("token" = paste(token, collapse = ", ")) %>%
        data.frame()
    })
  
  if (summarize) {
    res %<>%
      {do.call(rbind, .)} %>%
      tibble::add_column(
        "topic" = gsub(x = rownames(.), "\\..*", ""),
        .before = 1
      ) %>%
      tibble::tibble()
  } else {
    res %<>% lapply(tibble::tibble)
  }

  return(res)
}
