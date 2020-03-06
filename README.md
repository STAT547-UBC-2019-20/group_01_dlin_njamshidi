# Group 1: Medical Expenses

## Milestone 1

We have chosen Medical Expenses dataset from Kaggle's database. You can find our initial explorary data analysis in the link below:

https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone1.html

## Milestone 2

1. `load_data.R`
```
Rscript scripts/load_data.R --data_to_url=https://gist.github.com/meperezcuello/82a9f1c1c473d6585e750ad2e3c05a41/raw/d42d226d0dd64e7f5395a0eec1b9190a10edbc03/Medical_Cost.csv
```

2. `process_data.R`
```
Rscript scripts/process_data.R --file_path="data/raw/data.csv" --filename="processed_data.csv"
```

3. `explore_data.R`
```
Rscript scripts/explore_data.R --raw_data="data/raw/data.csv" --processed_data="data/processed/processed_data.csv" --path_to_images="images"
```