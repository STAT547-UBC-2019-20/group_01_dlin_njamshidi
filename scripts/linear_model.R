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

# read in command-line arguments
opt <- docopt(doc)

main <- function(processed_data,image_path,lm_path) {
  data <- read.csv(processed_data)
  
  model <-
    lm(charges ~ age + sex + bmi + children + smoker + region, data = data)
  
  plots <-
    png(paste(image_path, "lmplot%03d.png", sep = "/"))
  plot(model, ask = FALSE)
  dev.off()
  
  
  glanced <- glance(model)
  tidied <- tidy(model)
  augmented <- augment(model)
  
  augmented %>%
    ggplot(aes(x = .fitted, y = charges)) +
    geom_point() +
    geom_abline(slope = 1, colour = "blue") +
    coord_fixed() +
    theme_bw() +
    labs(title = "Real vs Fitted",
         x = "Fitted Values", y = "Real Values") +
    theme(plot.title = element_text(hjust = 0.5, face = "plain")) +
    ggsave(paste(image_path, "lmplot005.png", sep = "/"))
  
  # print successful message
  print(
    glue(
      "The linear regression plots have been successfully saved in the {image_path} directory."
    )
  )
  
  
  flist <-
    list(
      model = model,
      glanced = glanced,
      tidied = tidied,
      augmented = augmented
    )
  map2(flist, names(flist), ~ saveRDS(.x, paste0(lm_path, "/", .y , ".rds")))
  
  # print successful message
  print(
    glue(
      "The linear regression model, and its related statistics have been successfully saved in .rds format in the {lm_path} directory."
    )
  )
  
}

# call main function
main(
  opt$processed_data, opt$path_to_images, opt$path_to_lmdata
)