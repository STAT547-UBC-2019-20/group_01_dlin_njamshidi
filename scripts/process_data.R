# Author: Nima jamshidi
# date: 2020-03-05

# Description of the script and the command-line arguments
"This script wrangles the data and creates a new data file including the dummy variables for the categorical variables.

Usage: process_data.R --file_path=<path_to_raw_data_file> --filename=<output_file_name>" -> doc

# Load in the necessary packages
suppressMessages(library(tidyverse))
suppressMessages(library(docopt))
suppressMessages(library(psych))
suppressMessages(library(hablar))
suppressMessages(library(glue))
suppressMessages(library(here))

# Take in command-line arguments
opt <- docopt(doc)

# Main function
main <- function(path, name) {
  # check that the command-line argument given file exists
  if (!file.exists(path)) {
    stop(glue("The file {path} does not exist!"))
  }
  
  # Read in the file, and read each column into a certain type
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
  
  # wrangle the data to include dummy variables for factors
  data <- data %>%
    mutate(sex_dummy = as.numeric(sex),
           smoker_dummy = as.numeric(fct_relevel(smoker, "no"))) %>%
    cbind(as_tibble(psych::dummy.code(data$region)) %>% hablar::convert(hablar::int(1:4))) %>%
    select(-charges) %>%
    cbind(charges = data$charges) %>%
    mutate(age_range = case_when(
      age < 20 ~ glue("{min(age)}-20"),
      age >= 20 & age < 30 ~ "20-30",
      age >=30 & age < 40 ~ "30-40",
      age >=40 & age < 50 ~ "40-50",
      age >=50 & age < 60 ~ "50-60",
      age >=60 & age <= max(age) ~ glue("60-{max(age)}")
    ))
  
  # write the csv file out to specified file name to data/processed directory
  write_csv(data, here("data", "processed", name))
  
  # print out success message
  print(
    glue(
      "The data has been successfully wrangled and written to {here('data', 'processed', name)}."
    )
  )
}

# call the main function
main(opt$file_path, opt$filename)