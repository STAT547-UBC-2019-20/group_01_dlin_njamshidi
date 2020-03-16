# Tests
This directory will hold all the test files.

## Inline Tests

So far, no test files using the `testthat` package have been written, however some 'manual' tests have been written into the scripts.

1. [`load_data.R`](../scripts/load_data.R):
    ```
    # check if URL given exists
    if (!url.exists(url)) {
      stop(glue("The URL {url} does not exist!"))
    }
    ```
  
1. [`process_data.R`](../scripts/process_data.R):
    ```
    # check that the command-line argument given file exists
    if (!file.exists(path)) {
      stop(glue("The file {path} does not exist!"))
    }
    ```
  
1. [`explore_data.R`](../scripts/explore_data.R):
    ```
    # check if command-line files exist: the processed data
    if (!file.exists(processed_data)) {
      stop(glue("The file {processed_data} does not exist!"))
    }
    
    # if the path given includes the root directory, then, rewrite path to equal to 'relative' directory path from the root
    # this way the use of here can be used in the rest of the script
    root <- paste0(here(),"/")
    if (str_detect(path,root)) {
      path <- paste0(str_remove(path,root))
    }
    
    # if the directory does not exist, create the directory with parent directories
    if (!dir.exists(here(path))) {
      dir.create(here(path), recursive = TRUE)
    }
    ```
    
1. [`linear_model.R`](../scripts/linear_model.R):
    ```
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
    ```
    
1. [`knit.R`](../scripts/knit.R):
    ```
    # check if the Rmarkdown file to knit exists
    if(!file.exists(rmd)) {
      stop(glue("The Rmarkdown file {rmd} does not exist!"))
    }
    ```