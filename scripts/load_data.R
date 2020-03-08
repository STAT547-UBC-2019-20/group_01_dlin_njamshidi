# author: Diana Lin
# date: 2020-03-05

# Description of the script and the command-line arguments
"This script loads the data necessary from a URL, for exploratory data analysis.

Usage: load_data.R --data_to_url=<url_to_raw_data_file>" -> doc

# load packages
suppressMessages(library(tidyverse))
suppressMessages(library(docopt))
suppressMessages(library(here))
suppressMessages(library(RCurl))
suppressMessages(library(glue))

# where our data is: https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv

# read in command-line arguments
opt <- docopt(doc)

# main function
main <- function(url) {

  # check if URL given exists
  if (!url.exists(url)) {
    stop(glue("The URL {url} does not exist!"))
  }
  
  # downlaod the csv and read in each column into a certain type
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
  
  # write the data out into a csv file in data/raw/data.csv
  write_csv(costs, here("data","raw","data.csv"))
  
  # print successful message
  print(glue("The script has executed successfully! The data file has been downloaded and written to {here('data','raw','data.csv')}."))
}

# call main function
main(opt$data_to_url)
