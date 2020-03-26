# author: Diana Lin
# date: March 19, 2020

"This script creates the dashboard corresponding to our exploratory data analysis and linear regression.

Usage: app.R"

## Load libraries
suppressMessages(library(dash))
suppressMessages(library(dashCoreComponents))
suppressMessages(library(dashHtmlComponents))
suppressMessages(library(dashTable))
suppressMessages(library(plotly))
suppressMessages(library(tidyverse))
suppressMessages(library(corrplot))
suppressMessages(library(glue))
suppressMessages(library(scales))
suppressMessages(library(stringr))
suppressMessages(library(here))
suppressMessages(library(ggcorrplot))
suppressMessages(library(purrr))
## Make plots
data <- read_csv(
  here("data","processed","processed_data.csv"),
  col_types = cols(
    age = col_integer(),
    sex = readr::col_factor(),
    bmi = col_double(),
    children = col_integer(),
    smoker = readr::col_factor(),
    region = readr::col_factor(),
    sex_dummy = col_integer(),
    smoker_dummy = col_integer(),
    southeast = col_integer(),
    southwest = col_integer(),
    northwest = col_integer(),
    northeast = col_integer(),
    charges = col_double(),
    age_range = readr::col_factor()
  )
)
                              
make_age_plot <- function(breakdown = "sex") {
  p <- data %>% 
    ggplot(aes(x=age_range,fill=!!sym(breakdown))) +
    geom_bar(position = "dodge") +
    xlab("Age Ranges") +
    ylab("Count")+
    theme_bw() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  ggplotly(p)
}


## Assign components to variables
title <- htmlH1("Factors Affecting Medical Expenses")
authors <- htmlH4("By Diana Lin & Nima Jamshidi")
age_plot <- dccGraph(id = 'age', figure = make_age_plot())
vars <- tibble(label = c("Age Range", "Sex", "Smoking status", "USA Region"),
               value = colnames(data)[c(14,2,5,6)]
)

feat_dd <- dccDropdown(id = 'feat_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "sex")

## Create Dash instance

app <- Dash$new()

## Specify App layout
app$layout(
  htmlDiv(
    list(
      ### Add components here
      title,
      authors,
      age_plot,
      feat_dd
    )
  )
)

## App Callbacks
app$callback(
  output = list(id = 'age', property='figure'),
  params = list(input(id = 'feat_dd', property='value')),
  function(breakdown) {
    make_age_plot(breakdown)
  }
)

## Update Plot

## Run app

app$run_server(debug=TRUE)

# command to add dash app in Rstudio viewer:
# rstudioapi::viewer("http://127.0.0.1:8050")
