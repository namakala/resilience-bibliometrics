# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)

# List all raw data
raw <- list.files("data/raw", recursive = TRUE, full.names = TRUE) %>%
  set_names(gsub(x = ., ".*/|\\..+", ""))

# Source all functions
fun <- list.files("src/R", recursive = TRUE, full.names = TRUE, pattern = "*.R") %>%
  sapply(source)

# Analysis pipeline
list(

  # Query the database
  tar_target(query_pm, genQuery(type = "pubmed")),
  tar_target(dat_pm, DBquery(query_pm, type = "pubmed")),

  # Read query results as a dataframe
  tar_target(tbl_pm, bibliometrix::convert2df(dat_pm, dbsource = "pubmed", format = "api")),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
