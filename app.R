# author: Diana Lin
# date: March 19, 2020

"This script creates the dashboard corresponding to our exploratory data analysis and linear regression.
Usage: app.R"

## Load libraries
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(plotly))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(viridis))

## Read in data
data <- readRDS(here("data","processed","processed_data.rds"))

## Make plots
make_age_plot <- function(breakdown = "sex", scheme = "default") {
  p1 <- data %>% 
    ggplot(aes(x=age_range,fill=!!sym(breakdown))) +
    geom_bar(position = "dodge") +
    xlab("Age Ranges") +
    ylab("Count")+
    theme_bw() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  if (scheme == "viridis") {
    p1 <- p1 + scale_fill_viridis(discrete=TRUE)
  }
  
  ggplotly(p1)
}

make_facet_plot <- function(breakdown = "smoker", scheme = "default") {
  
  p2 <- data %>%
    select(c(age, sex, bmi, children, smoker, region, charges, age_range)) %>%
    ggplot(aes(x = bmi, y = charges, colour = !!sym(breakdown))) +
    geom_point() +
    theme_bw() +
    facet_grid(sex ~ region, labeller = label_both) +
    labs(x = 'BMI',
         y = 'Charges (USD)') +
    scale_y_continuous(labels = dollar)
  
  if (scheme == "viridis") {
    p2 <- p2 + scale_colour_viridis(discrete=TRUE)
  }
  
  ggplotly(p2)
}

make_stacked_bar <- function(breakdown = "sex", scheme = "viridis") {
  p3 <- data %>%
    group_by(!!sym(breakdown), region) %>%
    summarize(count = n()) %>%
    ggplot(aes(fill = !!sym(breakdown), x = region, y=count)) +
    geom_bar(position="stack", stat="identity") +
    theme_bw() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  
  if (scheme == "viridis") {
    p3 <- p3 + scale_fill_viridis(discrete = TRUE)
  }
  
  ggplotly(p3)
}

## Assign components to variables
title <- htmlH1("Factors Affecting Medical Expenses")
authors <- htmlH4("By Diana Lin & Nima Jamshidi")
age_plot <- dccGraph(id = 'age', figure = make_age_plot())
vars <- tibble(label = c("Age Range", "Sex", "Smoking status", "USA Region"),
               value = colnames(data)[c(14,2,5,6)]
)
feat_dd <- dccDropdown(id = 'feat_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "sex")

facet_plot <- dccGraph(id = 'facet', figure = make_facet_plot())

viridis_button <- dccRadioItems(id = 'viridis_button', 
                                options = list(
                                  list(label = 'Default', value = 'default'),
                                  list(label = 'Colour Blind', value = 'viridis')
                                ),
                                value = 'default')

# viridis_button <- dccChecklist(id = 'viridis_buton',
#                                options = list(
#                                  list("label" = "colour blind", "value" = "viridis")),
#                                value = list("default"))

stacked_plot <- dccGraph(id = 'stacked', figure = make_stacked_bar())

## Create Dash instance

app <- Dash$new()

## Specify App layout
app$layout(
  htmlDiv(
    list(
      ### Add components here
      title,
      authors,
      viridis_button,
      htmlLabel("Select colour breakdown:"),
      feat_dd,
      age_plot,
      facet_plot,
      stacked_plot
    )
  )
)

## App Callbacks
# app$callback(
#   output = list(id = 'age', property='figure'),
#   params = list(input(id = 'feat_dd', property='value')),
#   function(breakdown) {
#     make_age_plot(breakdown)
#   }
# )

app$callback(
  output = list(id = 'age', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value')),
  function(breakdown, scheme) {
    make_age_plot(breakdown, scheme)
  }
)

# app$callback(
#   output = list(id = 'facet', property='figure'),
#   params = list(input(id = 'feat_dd', property='value')),
#   function(breakdown) {
#     make_facet_plot(breakdown)
#   }
# )

app$callback(
  output = list(id = 'facet', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value')),
  function(breakdown, scheme) {
    make_facet_plot(breakdown, scheme)
  }
)

app$callback(
  output = list(id = 'stacked', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value')),
  function(breakdown, scheme) {
    make_stacked_bar(breakdown, scheme)
  }
)

## Update Plot

## Run app


app$run_server(debug=TRUE)

# command to add dash app in Rstudio viewer:
# rstudioapi::viewer("http://127.0.0.1:8050")