# author: Diana Lin
# date: 2020-03-14

# Description of the script and the command-line arguments
"This script knits the final draft of the report.

Usage: knit.R --finalreport=<final_report>" -> doc

# laod packages
library(docopt)
library(rmarkdown)
library(glue)

# read in command-line arguments
opt <- docopt(doc)

main <- function(rmd) {
  # check that the Rmarkdown file exists
  if(!file.exists(rmd)) {
    stop(glue("The Rmarkdown file {rmd} does not exist!"))
  }
  
  rmarkdown::render(rmd, c("html_document", "pdf_document"))
}

# call main function
main(opt$finalreport)