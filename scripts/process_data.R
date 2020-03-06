# Author: Nima jamshidi
# date: 2020-03-05

"This script creates a new data file including the dummy variables for the categorical variables.

Usage: load_data.R --file_path=<path_to_raw_data_file> --filename=<file_name>" -> doc

library(tidyverse)
library(docopt)
library(here)
library(psych)
library(hablar)
library(glue)

opt <- docopt(doc)

main <- function(path,name) {

  
  data <- read_csv(
    path,
    col_types = cols(
      age = col_integer(),
      sex = readr::col_factor(),
      bmi = col_double(),
      children = col_integer(),
      smoker = readr::col_factor(),
      region = readr::col_factor(),
      charges = col_double()
    )
  )
  
  data <- data %>%
    mutate(sex = as.numeric(sex),
           smoker = as.numeric(fct_relevel(smoker,"no"))
    ) %>% 
    cbind(  as_tibble(psych::dummy.code(data$region)) %>% hablar::convert(hablar::int(1:4))) %>% 
    select(-charges) %>%
    cbind(charges = data$charges)
  
  write_csv(data, glue("../data/processed/{name}.csv"))
  print("the data is successfully wrangled and saved.")
}



main(opt$file_path,opt$filename)