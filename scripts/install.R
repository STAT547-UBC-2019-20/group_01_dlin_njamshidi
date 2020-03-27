# author: Diana Lin
# date: March 18, 202

# list of required packages from the README
required_packages <-c("tidyverse","here","hablar","psych","corrplot","scales","glue","RCurl","docopt","broom","purrr","grid","gridExtra","png","tinytex","bookdown","fiery", "routr", "reqres", "htmltools", "base64enc", "plotly", "mime", "crayon", "devtools", "testthat","dash")

# Boolean vector of which ones are installed, 
boolean <- required_packages %in% installed.packages()

# Get indices of those that are not installed
indices <- which(boolean == FALSE)


# if uninstalled packages is not 0, install those packages
if (length(indices) != 0) {
  # remove 'dash' since it needs to be installed using devtools
  required_packages <- required_packages[-length(required_packages)]
  
  # remove indices of dash
  indices <- indices[!indices %in% length(required_packages)]
  uninstalled <- required_packages[indices]
  print("Installing the following packages:")
  print(uninstalled)
  install.packages(uninstalled, dependencies = TRUE, repo="http://cran.rstudio.com/")
  
  if ("devtools" %in% installed.packages()) {
    if (!all(c("dash", "dashCoreComponents","dashHtmlComponents", "dashTable") %in% installed.packages())) {
      print("Installing DashR from GitHub...")
      devtools::install_github('plotly/dashR', upgrade = TRUE)
    }
    if (!"dashDaq" %in% installed.packages()) {
      print("Installing dashDaq from GitHub...")
      devtools::install_github('plotly/dash-daq', upgrade = TRUE)
    }
    print("Checking if DashR was installed correctly...")
    source(here::here("scripts","check_dash.R"))
  }
} else {
  print("All required packages are already installed!")
}