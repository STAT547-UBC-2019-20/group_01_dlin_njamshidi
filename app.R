# author: Diana Lin
# date: March 19, 2020

"This script creates the dashboard corresponding to our exploratory data analysis and linear regression.
Usage: app.R"

## Load libraries
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(dashDaq)
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(plotly))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(reshape2))

## Read in data
data <- readRDS(here("data","processed","processed_data.rds"))

## Make plots
make_age_plot <- function(breakdown = "sex", scheme = "default", theme_select = "minimal") {
  p1 <- data %>% 
    ggplot(aes(x=age_range,fill=!!sym(breakdown))) +
    geom_bar(position = "dodge") +
    xlab("Age Ranges") +
    ylab("Count")
  
  if (scheme == "viridis") {
    p1 <- p1 + scale_fill_viridis(discrete=TRUE)
  }
  
  if(theme_select == "minimal") {
    p1 <- p1 + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "gray") {
    p1 <- p1 + theme_gray() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "classic") {
    p1 <- p1 + theme_classic() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "light") {
    p1 <- p1 + theme_light() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "dark") {
    p1 <- p1 + theme_dark() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "bw") {
    p1 <- p1 + theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else {
    p1 <- p1 + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  }
  
  ggplotly(p1)
}

make_facet_plot <- function(breakdown = "smoker", scheme = "default", theme_select = "minimal") {
  
  p2 <- data %>%
    select(c(age, sex, bmi, children, smoker, region, charges, age_range)) %>%
    ggplot(aes(x = bmi, y = charges, colour = !!sym(breakdown))) +
    geom_point() +
    facet_grid(sex ~ region, labeller = label_both) +
    labs(x = 'BMI',
         y = 'Charges (USD)') +
    scale_y_continuous(labels = dollar)
  
  if (scheme == "viridis") {
    p2 <- p2 + scale_colour_viridis(discrete=TRUE)
  }
  
  if(theme_select == "minimal") {
    p2 <- p2 + theme_minimal()
  } else if (theme_select == "gray") {
    p2 <- p2 + theme_gray()
  } else if (theme_select == "classic") {
    p2 <- p2 + theme_classic()
  } else if (theme_select == "light") {
    p2 <- p2 + theme_light()
  } else if (theme_select == "dark") {
    p2 <- p2 + theme_dark()
  } else if (theme_select == "bw") {
    p2 <- p2 + theme_bw()
  }
  
  ggplotly(p2)
}

make_stacked_bar <- function(breakdown = "sex", scheme = "viridis", theme_select = "minimal") {
  p3 <- data %>%
    group_by(!!sym(breakdown), region) %>%
    summarize(count = n()) %>%
    ggplot(aes(fill = !!sym(breakdown), x = region, y=count)) +
    geom_bar(position="stack", stat="identity")
  
  if (scheme == "viridis") {
    p3 <- p3 + scale_fill_viridis(discrete = TRUE)
  }
  
  if(theme_select == "minimal") {
    p3 <- p3 + theme_minimal() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "gray") {
    p3 <- p3 + theme_gray() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "classic") {
    p3 <- p3 + theme_classic() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "light") {
    p3 <- p3 + theme_light() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "dark") {
    p3 <- p3 + theme_dark() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else if (theme_select == "bw") {
    p3 <- p3 + theme_bw() +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  } else {
    p3 <- p3  +  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  }
  
  ggplotly(p3)
}

make_cor_plot <- function(layout = "lower", diag = "TRUE", scheme = "default", labels = "FALSE", theme_select = "minimal"){
  costs <- readRDS(here("data","explore","correlation.rds"))
  
  # Get lower
  get_lower_tri<-function(df){
    df[lower.tri(df)] <- NA
    return(df)
  }
  # Get upper
  get_upper_tri <- function(df){
    df[upper.tri(df)]<- NA
    return(df)
  }
  
  rm_diag <- function(df) {
    filter(df, Var1 != Var2)
  }
  if (layout == "upper") {
    melted_costs <- melt(get_upper_tri(costs), na.rm = TRUE)
  } else if (layout == "lower") {
    melted_costs <- melt(get_lower_tri(costs), na.rm = TRUE)
  } else {
    melted_costs <- melt(costs)
  }
  # melted_costs <-
  #   case_when(
  #     layout == "upper" ~ melt(get_upper_tri(costs), na.rm = TRUE),
  #     layout == "lower" ~ melt(get_lower_tri(costs), na.rm = TRUE),
  #     layout == "full" ~ melt(costs)
  #   )
  
  if (diag == "FALSE") {
    melted_costs <- rm_diag(melted_costs)
  }
  
  p4 <- melted_costs %>%
    ggplot(aes(Var2, Var1, fill = value)) +
    geom_tile(color = "white") +
   # theme_minimal() +
    theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) +
    xlab("") +
    ylab("")
  
  if (scheme == "viridis") {
    p4 <- p4 + scale_fill_viridis(
      limit = c(-1, 1),
      direction = 1
    ) 
  } else {
    p4 <- p4 + scale_fill_gradient2(
      low = "blue",
      high = "red",
      mid = "white",
      midpoint = 0,
      limit = c(-1, 1),
      space = "Lab",
      name = ""
    ) 
  }
  
  if (labels == "TRUE") {
    p4 <- p4 + geom_text(aes(Var2, Var1, label = value), color = "black", size = 4)
  }
  
  if(theme_select == "minimal") {
    p4 <- p4 + theme_minimal() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else if (theme_select == "gray") {
    p4 <- p4 + theme_gray() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else if (theme_select == "classic") {
    p4 <- p4 + theme_classic() + ttheme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else if (theme_select == "light") {
    p4 <- p4 + theme_light() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else if (theme_select == "dark") {
    p4 <- p4 + theme_dark() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else if (theme_select == "bw") {
    p4 <- p4 + theme_bw() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  } else {
    p4 <- p4 + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12)) 
  }
    
  ggplotly(p4)
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

# viridis_button <- daqToggleSwitch(id = 'my-toggle-switch',
#                                   value = FALSE)

stacked_plot <- dccGraph(id = 'stacked', figure = make_stacked_bar())
corr_plot <- dccGraph(id = 'corr', figure = make_cor_plot())

corr_layout <- dccRadioItems(id = 'layout_button',
                             options = list(
                               list(label = "Lower", value = "lower"),
                               list(label = "Upper", value = "upper"),
                               list(label = "Full", value = "full")
                             ),
                             value = "lower")
corr_diag <- dccRadioItems(id = 'diag_button',
                           options = list(
                             list(label = "Diagonal ON", value = "TRUE"),
                             list(label = "Diagonal OFF", value = "FALSE")
                           ), value = "TRUE")
corr_label <- dccRadioItems(id = 'lab_button',
                            options = list(
                              list(label = "Labels ON", value = "TRUE"),
                              list(label = "Labels OFF", value = "FALSE")
                            ), value = "FALSE")

themes <- tibble(label = c("Gray", "Black and white", "Light", "Dark", "Minimal", "Classic", "Default"),
                 value = c("gray", "bw", "light", "dark", "minimal", "classic", "default"))
theme_dd <-
  dccDropdown(
    id = 'themes',
    options = map(1:nrow(themes), function (i)
      list(label = themes$label[i], value = themes$value[i])),
    value = "minimal"
  )
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
      theme_dd,
      htmlLabel("Select colour breakdown:"),
      feat_dd,
      age_plot,
      facet_plot,
      stacked_plot,
      corr_layout,
      corr_plot,
      corr_diag,
      corr_label
    )
  )
)

app$callback(
  output = list(id = 'age', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value'),
                input(id = 'themes', property='value')),
  function(breakdown, scheme, theme) {
    make_age_plot(breakdown, scheme, theme)
  }
)

app$callback(
  output = list(id = 'facet', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value'),
                input(id = 'themes', property='value')),
  function(breakdown, scheme, theme) {
    make_facet_plot(breakdown, scheme, theme)
  }
)

app$callback(
  output = list(id = 'stacked', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='value'),
                input(id = 'themes', property='value')),
  function(breakdown, scheme, theme) {
    make_stacked_bar(breakdown, scheme,theme)
  }
)

app$callback(
  output = list(id = 'corr', property = 'figure'),
  params = list(input(id = 'layout_button', property='value'),
                input(id = 'diag_button', property = 'value'),
                input(id = 'viridis_button', property='value'),
                input(id = 'lab_button', property='value'),
                input(id = 'themes', property='value')),
  function(layout, diag, scheme,label,theme) {
    make_cor_plot(layout,diag,scheme,label, theme)
  }
)

## Update Plot

## Run app


app$run_server(debug=TRUE)

# command to add dash app in Rstudio viewer:
# rstudioapi::viewer("http://127.0.0.1:8050")