# Group 1: Medical Expenses

This repository holds the STAT 547 Group Project, for Group 1: Diana Lin and Nima Jamshidi. The dataset we have chosen to work with is the "Medical Expenses" dataset used in the book [Machine Learning with R](https://www.amazon.com/Machine-Learning-R-Brett-Lantz/dp/1782162143), by Brett Lantz. This dataset was extracted from [Kaggle](https://www.kaggle.com/mirichoi0218/insurance/home) by Github user [\@meperezcuello](https://gist.github.com/meperezcuello). The information about this dataset has been extracted from their [GitHub Gist](https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41).

## Usage

1. Clone this repo
    ```
    git clone https://github.com/STAT547-UBC-2019-20/group_01_dlin_njamshidi.git
    ```

1. Ensure the following packages are installed:
    - `tidyverse`: `dplyr`, `tidyr`, `ggplot2`, `readr`
    - `here`
    - `hablar`
    - `psych`
    - `corrplot`
    - `scales`
    - `glue`
    - `RCurl`
    - `docopt`
    - `broom`
    - `purrr`
    - `grid`
    - `gridExtra`
    - `png`
    - `tinytex`
    
    To install all these packages in your R Console:
    ```
    install.packages(c("tidyverse","here","hablar","psych","corrplot","scales","glue","RCurl","docopt","broom","purrr","grid","gridExtra","png","tinytex"))
    ```
    
### Running the whole pipeline

1. Clean the repository to undo any residual incomplete analysis
    ```
    make clean
    ```
  
1. Run the entire analysis pipeline
    ```
    make all
    ```
  
### Running each step using the Makefile

1. Download the data
    ```
    make data/raw/data.csv
    ```
1. Process the data
    ```
    make data/processed/processed_data.csv
    ```
1. Perform exploratory analysis
    ```
    make images/age_histogram.png images/corrplot.png images/facet.png images/region_barchart.png
    ```
1. Perform linear regression
    ```
    make data/linear_model/model.rds data/linear_model/tidied.rds data/linear_model/glanced.rds data/linear_model/augmented.rds images/lmplot001.png images/lmplot002.png images/lmplot003.png images/lmplot004.png images/lmplot005.png
    ```
1. Knit the final report
    ```
    make docs/milestone3.html docs/milestone3.pdf
    ```
  
### Running each R script individually

1. Run the following scripts (in order) with the appropriate arguments specified
    1. Download the data
        ```
        Rscript scripts/load_data.R --data_to_url="https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv"
        ```
    1. Wrangle/clean/process your data 
        ```
        Rscript scripts/process_data.R --file_path="data/raw/data.csv" --filename="processed_data.csv"
        ```
    1. Conduct exploratory data analysis
        ```
        Rscript scripts/explore_data.R --processed_data="data/processed/processed_data.csv" --path_to_images="images"
        ```
    1. Conduct linear regression
        ```
        Rscript scripts/linear_model.R --processed_data="data/processed/processed_data.csv" --path_to_images="images" --path_to_lmdata="data/linear_model"
        ```
    1. Knit the final report
        ```
        Rscript scripts/knit.R --finalreport="docs/milestone3.Rmd"
        ```

## Milestones

### Milestone 1

For Milestone 1, you can find our initial explorary data analysis in the link below:

https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone1.html

### Milestone 2

For Milestone 2, you can find the scripts to load, process, and conduct exploratory data analysis in the [`scripts/`](scripts/) directory. The first draft of our report can be found [here](https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone2.html).

1. `load_data.R`
    ```
    Rscript scripts/load_data.R --data_to_url=https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv
    ```

1. `process_data.R`
    ```
    Rscript scripts/process_data.R --file_path="data/raw/data.csv" --filename="processed_data.csv"
    ```

1. `explore_data.R`
    ```
    Rscript scripts/explore_data.R --processed_data="data/processed/processed_data.csv" --path_to_images="images"
    ```

### Miletone 3

For Milestone3, the script to knit the final report is [`scripts/knit.R`](scripts/knit.R). The final report can be here in [HTML](https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone3.html) and [PDF](https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone3.pdf).

1. `linear_model.R`
    ```
    Rscript scripts/linear_model.R --processed_data="data/processed/processed_data.csv" --path_to_images="images" --path_to_lmdata="data/linear_model"
    ```
    
1. `knit.R`
    ```
    Rscript scripts/knit.R --finalreport="docs/milestone3.Rmd"
    ```
    
1. `Makefile`
    ```
    make
    ```
