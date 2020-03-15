# Tests
This directory will hold all the test files.

## In-script Tests

So far, no test files using the `testthat` package have been written, however some 'manual' tests have been written into the scripts.

1. `load_data.R` on [L24-27](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/load_data.R#L24-25):
  ```
  # check if URL given exists
  if (!url.exists(url)) {
    stop(glue("The URL {url} does not exist!"))
  }
  ```
  
1. `process_data.R` on [L22-25](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/process_data.R#L22):
  ```
  # check that the command-line argument given file exists
  if (!file.exists(path)) {
    stop(glue("The file {path} does not exist!"))
  }
  ```
  
1. `explore_data.R` on [L24-27](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/explore_data.R#L24), [L29-34](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/explore_data.R#L29), [L36-39](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/explore_data.R#L36):
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
  
1. `knit.R` on [L18-21](https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi/blob/f9807e439b117378efa1674ff061fec7a25afea4/scripts/knit.R#L18):
  ```
  # check if the Rmarkdown file to knit exists
  if(!file.exists(rmd)) {
    stop(glue("The Rmarkdown file {rmd} does not exist!"))
  }
  ```