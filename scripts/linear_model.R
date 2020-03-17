# author: Nima Jamshidi
# date: 2020-03-14

# Description of the script and the command-line arguments
"This script does a linear regression on our data and exports the plots and the model.

Usage: linear_model.R --processed_data=<processed_data> --path_to_images=<path_to_images> --path_to_lmdata=<path_to_lmdata>" -> doc

# laod packages
library(docopt)
library(tidyverse)
library(broom)
library(purrr)
library(glue)
library(grid)
library(gridExtra)
library(png)
library(here)

# read in command-line arguments
opt <- docopt(doc)

main <- function(processed_data,image_path,lm_path) {
  
  # check if paths given was relative or absolute
  # if path given includes the root, then remove root to use `here` package.
  root <- paste0(here(),"/")
  if (str_detect(processed_data,root)) {
    processed_data <- paste0(str_remove(processed_data,root))
  }
  
  if (str_detect(image_path,root)) {
    image_path <- paste0(str_remove(image_path,root))
  }
  
  if (str_detect(lm_path,root)) {
    lm_path <- paste0(str_remove(lm_path,root))
  }
  
  # check if processed_data file exists
  if (!file.exists(processed_data)) {
    stop(glue("The file {processed_data} does not exist!"))
  }
  
  # if the directory does not exist, create the directory with parent directories
  if (!dir.exists(here(image_path))) {
    dir.create(here(image_path), recursive = TRUE)
  }
  
  if (!dir.exists(here(lm_path))) {
    dir.create(here(lm_path), recursive = TRUE)
  }
  #read the processed data.
  data <- read.csv(here(processed_data))
  #conduct linear regression
  model <-
    lm(charges ~ age + sex + bmi + children + smoker + region, data = data)
  #plot the first 4 diagnostics graphs
  plots <-
    png(here(image_path, "lmplot%03d.png"))
  plot(model, ask = FALSE)
  dev.off()
  
  #linear regression statistics 
  glanced <- glance(model)
  tidied <- tidy(model)
  augmented <- augment(model)
  #plot the fifth diagnostics graph
  augmented %>%
    ggplot(aes(x = .fitted, y = charges)) +
    geom_point() +
    geom_abline(slope = 1, colour = "blue") +
    coord_fixed() +
    theme_bw() +
    labs(title = "Real vs Fitted",
         x = "Fitted Values", y = "Real Values") +
    theme(plot.title = element_text(hjust = 0.5, face = "plain")) +
    ggsave(here(image_path, "lmplot005.png"))
  
  # print successful message
  print(
    glue(
      "The linear regression plots have been successfully saved in the {here(image_path)} directory."
    )
  )
  
  #save the statistics in separate .rds files
  flist <-
    list(
      model = model,
      glanced = glanced,
      tidied = tidied,
      augmented = augmented
    )
  map2(flist, names(flist), ~ saveRDS(.x, paste0(here(lm_path), "/", .y , ".rds")))
  
  # print successful message
  print(
    glue(
      "The linear regression model, and its related statistics have been successfully saved in .rds format in the {here(lm_path)} directory."
    )
  )
  
}

# call main function
main(
  opt$processed_data, opt$path_to_images, opt$path_to_lmdata
)