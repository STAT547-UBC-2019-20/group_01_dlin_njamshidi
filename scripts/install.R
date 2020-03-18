# author: Diana Lin
# date: March 18, 202

# list of required packages from the README
required_packages <-c("tidyverse","here","hablar","psych","corrplot","scales","glue","RCurl","docopt","broom","purrr","grid","gridExtra","png","tinytex","bookdown")

# Boolean vector of which ones are installed, 
boolean <- required_packages %in% installed.packages()

# Get indices of those that are not installed
indices <- which(boolean == FALSE)

# if uninstalled packages is not 0, install those packages
if (length(indices) != 0) {
  uninstalled <- required_packages[indices]
  print("Installing the following packages:")
  print(uninstalled)
  install.packages(uninstalled, dependencies = TRUE, repo="http://cran.rstudio.com/")
} else {
  print("All required packages are already installed!")
}