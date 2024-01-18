# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "bibliometrix", "crew")
sapply(pkgs, library, character.only = TRUE)

# Source all functions
fun <- list.files("src/R", recursive = TRUE, full.names = TRUE, pattern = "*.R") %>%
  sapply(source)

# List all references
ref <- list.files(
    "data/raw", recursive = TRUE, full.names = TRUE, pattern = "*.(csv|txt|bib)"
  ) %>%
  set_names(gsub(x = ., ".*/|\\..+", ""))

# Set option for targets
tar_option_set(
  packages   = pkgs,
  error      = "continue",
  memory     = "transient",
  controller = crew_controller_local(worker = 4),
  storage    = "worker",
  retrieval  = "worker",
  garbage_collection = TRUE
)

seed <- 1810

# Analysis pipeline
list(

  # Read exported dataset
  tar_target(bibs, readBib(ref)),
  tar_target(bib,  mergeBib(bibs)),

  # Perform bibliometrics analysis
  tar_target(analyzed_bib, bibliometrix::biblioAnalysis(bib)),

  # Fit in a structural topic model
  tar_target(ntopic, c(5:20)),
  tar_map(
    unlist = FALSE,
    values = tibble::tibble("n" = (1:3)),

    # Tokenize the abstracts
    tar_target(token, tokenize(bib, wordlist = "data/ref/awl.txt", n = n)),
    tar_target(token_count, countToken(token)),
    tar_target(token_stat,  getTokenStat(token)),

    # Form a document-frequency matrix
    tar_target(dfm, mkDocMatrix(token, bib)),
    tar_target(stm, genTopic(dfm, K = ntopic, seed = seed), pattern = map(ntopic), iteration = "list"),

    # Obtain the optimum parameters
    tar_target(eval_topic,     evalTopic(stm, dfm),  pattern = map(stm), iteration = "list"),
    tar_target(eval_summaries, colMeans(eval_topic), pattern = map(eval_topic), iteration = "list"),
    tar_target(eval_summary,   do.call(rbind, eval_summaries) %>% data.frame()),
    tar_target(optim_param,    selTopicParam(eval_summary)),

    # Extract labels
    tar_target(topic_label, getLabel(stm[[optim_param]], summarize = TRUE)),
    tar_target(topic_token, getTopic(stm[[optim_param]], n = 10)),
    tar_target(topic_doc,   getTopic(stm[[optim_param]], type = "gamma", n = 1)),

    # Flatten the token for data augmenting
    tar_target(token_flat, flatten(token, "doi", "word", collapse = "; "))

  ),

  # Augment topic to the bibliometrics data frame
  tar_target(
    bib_aug,
    augmentBib(
      bib,
      topic_doc = list(topic_doc_1, topic_doc_2, topic_doc_3),
      token     = list(token_flat_1, token_flat_2, token_flat_3)
    )
  ),

  # Reference data from WoS for network analysis
  tar_target(sub_bib, bib_aug %>% subset(.$DB == "ISI")),

  # Extract the network of articles
  tar_map(
    unlist = FALSE,
    values = tibble::tibble(
      "analysis" = c("collaboration", "co-occurrences", "co-citation"),
      "network"  = c("authors", "keywords", "references")
    ),
    tar_target(net_bib, mkNetwork(sub_bib, analysis = analysis, network = network, short = TRUE))
  ),

  tar_target(net_bib_plt, vizNetwork(net_bib_collaboration_authors, n = 200)),

  # Map the theme based on coupled DOI on modelled topics
  tar_map(
    unlist = FALSE,
    values = tibble::tibble("topic" = paste0("topic", c("1", "2", ""))),
    tar_target(map_bib, mapTheme(sub_bib, topic_var = topic))
  ),

  # Generate historical direct citation network for papers cited at least 1000x
  tar_target(net_hist, histNetwork(sub_bib, min.citations = 1000, sep = ";")),
  tar_target(net_hist_plt, histPlot(net_hist, n = 15, size = 10, labelsize = 5)),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
