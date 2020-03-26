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

## Make plots

## Assign components to variables
title <- htmlH1("Factors Affecting Medical Expenses")
authors <- htmlH4("By Diana Lin & Nima Jamshidi")

## Create Dash instance

app <- Dash$new()

## Specify App layout
app$layout(
  htmlDiv(
    list(
      ### Add components here
      title,
      authors
    )
  )
)

## App Callbacks

## Update Plot

## Run app

app$run_server(debug=TRUE)

# command to add dash app in Rstudio viewer:
# rstudioapi::viewer("http://127.0.0.1:8050")