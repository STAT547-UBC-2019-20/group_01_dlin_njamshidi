# author: Diana Lin
# date: 2020-03-14

.PHONY: all clean

all: docs/milestone3.html docs/milestone3.pdf

# Download the raw data from an URL
data/raw/data.csv: scripts/load_data.R
	Rscript scripts/load_data.R --data_to_url="https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv"
	
# Process the data for analysis
data/processed/processed_data.csv: scripts/process_data.R data/raw/data.csv
	Rscript scripts/process_data.R --file_path="data/raw/data.csv" --filename="processed_data.csv"

# Perform exploratory data analysis
images/age_histogram.png images/corrplot.png images/facet.png images/region_barchart.png: scripts/explore_data.R data/processed/processed_data.csv
	Rscript scripts/explore_data.R --processed_data="data/processed/processed_data.csv" --path_to_images="images"

# Perform linear regression
# PLACEHOLDER

docs/milestone3.html docs/milestone3.pdf: scripts/knit.R docs/milestone3.Rmd images/age_histogram.png images/corrplot.png images/facet.png images/region_barchart.png
	Rscript scripts/knit.R --finalreport="docs/milestone3.Rmd"

clean:
	rm -f data/raw/*.csv
	rm -f data/processed/*.csv
	rm -f images/*.png
	rm -f milestone3.html
	rm -f milestone3.pdf