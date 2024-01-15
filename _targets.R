# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "bibliometrix", "crew")
sapply(pkgs, library, character.only = TRUE)

# List all references
ref <- list.files(
    "data/raw", recursive = TRUE, full.names = TRUE, pattern = "*.(csv|txt|bib)"
  ) %>%
  set_names(gsub(x = ., ".*/|\\..+", ""))

# Source all functions
fun <- list.files("src/R", recursive = TRUE, full.names = TRUE, pattern = "*.R") %>%
  sapply(source)

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

  # Reference data from WoS for network analysis
  tar_target(sub_bib, bib %>% subset(.$DB == "ISI")),

  # Extract the network of articles
  tar_map(
    unlist = FALSE,
    values = tibble::tibble(
      "analysis" = c("collaboration", "co-occurrences", "co-citation", "coupling"),
      "network"  = c("authors", "keywords", "references", "sources")
    ),
    tar_target(network_bib, mkNetwork(sub_bib, analysis = analysis, network = network))
  ),

  # Tokenize the abstract into ngram then perform topic modelling
  tar_target(ntopic, c(5:20)),
  tar_map(
    unlist = FALSE,
    values = tibble::tibble("n" = (1:3)),
    tar_target(token, tokenize(bib, wordlist = "data/ref/awl.txt", n = n)),
    tar_target(token_count, countToken(token)),
    tar_target(token_stat,  getTokenStat(token)),
    tar_target(dfm, mkDocMatrix(token, bib)),
    tar_target(stm, genTopic(dfm, K = ntopic, seed = seed), pattern = map(ntopic), iteration = "list"),
    tar_target(eval_topic,  evalTopic(stm, dfm),  pattern = map(stm), iteration = "list"),
    tar_target(eval_summaries, colMeans(eval_topic), pattern = map(eval_topic), iteration = "list"),
    tar_target(eval_summary,   do.call(rbind, eval_summaries) %>% data.frame()),
    tar_target(optim_param, selTopicParam(eval_summary)),
    tar_target(topic_label, getLabel(stm[[optim_param]])),
    tar_target(topic_token, getTopic(stm[[optim_param]])),
    tar_target(topic_doc,   getTopic(stm[[optim_param]], type = "gamma"))
  ),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
