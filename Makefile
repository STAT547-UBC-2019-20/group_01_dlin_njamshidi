# author: Diana Lin
# date: 2020-03-14

.PHONY: all clean install

all: install docs/milestone3.html docs/milestone3.pdf

# install required packages
install:
	Rscript scripts/install.R
	
# Download the raw data from an URL
data/raw/data.csv: scripts/load_data.R scripts/install.R
	Rscript scripts/load_data.R --data_to_url="https://gist.githubusercontent.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv"
	
# Process the data for analysis
data/processed/processed_data.csv: scripts/process_data.R data/raw/data.csv
	Rscript scripts/process_data.R --file_path="data/raw/data.csv" --filename="processed_data.csv"

# Perform exploratory data analysis
images/age_histogram.png images/corrplot.png images/facet.png images/region_barchart.png data/explore/correlation.rds: scripts/explore_data.R data/processed/processed_data.csv
	Rscript scripts/explore_data.R --processed_data="data/processed/processed_data.csv" --path_to_images="images" --path_to_data="data/explore"

# Perform linear regression
data/linear_model/model.rds data/linear_model/tidied.rds data/linear_model/glanced.rds data/linear_model/augmented.rds images/lmplot001.png images/lmplot002.png images/lmplot003.png images/lmplot004.png images/lmplot005.png: scripts/linear_model.R data/processed/processed_data.csv
	Rscript scripts/linear_model.R --processed_data="data/processed/processed_data.csv" --path_to_images="images" --path_to_lmdata="data/linear_model"
	
# to Knit the final report in PDF and HTML
docs/milestone3.html docs/milestone3.pdf: scripts/knit.R docs/milestone3.Rmd images/age_histogram.png images/corrplot.png images/facet.png images/region_barchart.png data/linear_model/model.rds data/linear_model/tidied.rds data/linear_model/glanced.rds data/linear_model/augmented.rds images/lmplot001.png images/lmplot002.png images/lmplot003.png images/lmplot004.png images/lmplot005.png data/explore/correlation.rds
	Rscript scripts/knit.R --finalreport="docs/milestone3.Rmd"

# to clean the repository and "undo" the analysis
clean:
	rm -f data/raw/*.csv
	rm -f data/processed/*.csv
	rm -f data/linear_model/*.rds
	rm -f images/*.png
	rm -f milestone3.html
	rm -f milestone3.pdf