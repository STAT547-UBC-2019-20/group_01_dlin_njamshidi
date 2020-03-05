# author: Diana Lin
# date: 2020-03-05

"This script loads the data necessary for exploratory data analysis.

Usage: load_data.R --data_to_url=<url_to_raw_data_file>" -> doc

suppressMessages(library(tidyverse))
suppressMessages(library(docopt))
suppressMessages(library(here))

# where are data is: https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv

opt <- docopt(doc)

main <- function(url) {
  costs <- read_csv(url,
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
  
  write_csv(costs, here("data","raw_data","data.csv"))
  
  print("The script has executed successfully!")
}

main(opt$data_to_url)
