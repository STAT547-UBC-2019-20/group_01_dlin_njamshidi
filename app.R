# author: Diana Lin
# date: March 19, 2020

"This script creates the dashboard corresponding to our exploratory data analysis and linear regression.
Usage: app.R"

# load libraries ----
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
suppressPackageStartupMessages(library(glue))

## Read in data
data <- readRDS(here("data","processed","processed_data.rds"))

## Make plots ----

# Tibble of factors
vars <- tibble(label = c("Age Range", "Sex", "Smoking Status", "USA Region"),
               value = colnames(data)[c(14,2,5,6)]
)

# Tibble of themes
themes <- tibble(label = c("Gray", "Black and white", "Light", "Dark", "Minimal", "Classic", "Default"),
                 value = c("gray", "bw", "light", "dark", "minimal", "classic", "default"))

make_age_plot <- function(xaxis = "age_range", breakdown = "smoker", viridis = FALSE, theme_select = "minimal") {
  
  title <- vars$label[vars$value == breakdown]
  xaxis_val <- vars$label[vars$value == xaxis]
  
  p1 <- data %>% 
    ggplot(aes(x=!!sym(xaxis),fill=!!sym(breakdown))) +
    geom_bar(position = "dodge") +
    xlab(xaxis_val) +
    ylab("Count") +
    ggtitle(glue("Distribution of {title} Across {xaxis_val}"))
  
  if (viridis == TRUE) {
    p1 <- p1 + scale_fill_viridis(discrete=TRUE)
  }
  
  if(theme_select == "minimal") {
    p1 <- p1 + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "gray") {
    p1 <- p1 + theme_gray() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "classic") {
    p1 <- p1 + theme_classic() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "light") {
    p1 <- p1 + theme_light() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "dark") {
    p1 <- p1 + theme_dark() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "bw") {
    p1 <- p1 + theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else {
    p1 <- p1 + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  }
  
  ggplotly(p1)
}

make_facet_plot <- function(breakdown = "smoker", viridis = FALSE, theme_select = "minimal") {
  
  p2 <- data %>%
    select(c(age, sex, bmi, children, smoker, region, charges, age_range)) %>%
    ggplot(aes(x = bmi, y = charges, colour = !!sym(breakdown))) +
    geom_point() +
    facet_grid(sex ~ region, labeller = label_both) +
    labs(x = 'BMI',
         y = 'Charges (USD)') +
    scale_y_continuous(labels = dollar) +
    ggtitle("Exploring the Relationship Between BMI and Medical Costs")
  
  if (viridis == TRUE) {
    p2 <- p2 + scale_colour_viridis(discrete=TRUE)
  }
  
  if(theme_select == "minimal") {
    p2 <- p2 + theme_minimal() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "gray") {
    p2 <- p2 + theme_gray() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "classic") {
    p2 <- p2 + theme_classic() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "light") {
    p2 <- p2 + theme_light() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "dark") {
    p2 <- p2 + theme_dark() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else if (theme_select == "bw") {
    p2 <- p2 + theme_bw() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  } else {
    p2 <- p2 + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  }
  
  ggplotly(p2)
}

make_cor_plot <- function(layout = "lower", diag = FALSE, viridis = FALSE, labels = TRUE, theme_select = "minimal"){
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
  
  if (diag == FALSE) {
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
    ylab("") +
    ggtitle("Correlation Between All Variables")
  
  if (viridis == TRUE) {
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
  
  if (labels == TRUE) {
    p4 <- p4 + geom_text(aes(Var2, Var1, label = value), color = "black", size = 4)
  }
  
  if(theme_select == "minimal") {
    p4 <- p4 + theme_minimal() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else if (theme_select == "gray") {
    p4 <- p4 + theme_gray() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else if (theme_select == "classic") {
    p4 <- p4 + theme_classic() + ttheme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else if (theme_select == "light") {
    p4 <- p4 + theme_light() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else if (theme_select == "dark") {
    p4 <- p4 + theme_dark() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else if (theme_select == "bw") {
    p4 <- p4 + theme_bw() + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  } else {
    p4 <- p4 + theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  }
    
  ggplotly(p4)
}

## Assign components to variables ----
title <- htmlH1("Factors Affecting Medical Expenses")
authors <- htmlH4("By Diana Lin & Nima Jamshidi")
age_plot <- dccGraph(id = 'age', figure = make_age_plot())

feat_dd <- dccDropdown(id = 'feat_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "smoker")

facet_plot <- dccGraph(id = 'facet', figure = make_facet_plot())

viridis_button <- daqBooleanSwitch(id = 'viridis_button',
                                   on = FALSE,
                                   label = "Viridis Toggle:",
                                   labelPosition = "top")

# stacked_plot <- dccGraph(id = 'stacked', figure = make_stacked_bar())
corr_plot <- dccGraph(id = 'corr', figure = make_cor_plot())

corr_layout <- dccRadioItems(id = 'layout_button',
                             options = list(
                               list(label = "Lower", value = "lower"),
                               list(label = "Upper", value = "upper"),
                               list(label = "Full", value = "full")
                             ),
                             value = "lower")

corr_diag <- daqBooleanSwitch(id = 'diagonal_toggle',
                              on = FALSE,
                              label = "Diagonal Toggle:",
                              labelPosition = "top")

corr_label <- daqBooleanSwitch(id = 'label_toggle',
                               on = FALSE,
                               label = 'Label Toggle:',
                               labelPosition = "top")

theme_dd <-
  dccDropdown(
    id = 'themes',
    options = map(1:nrow(themes), function (i)
      list(label = themes$label[i], value = themes$value[i])),
    value = "minimal"
  )

reset <- htmlButton("Reset", id = 'reset_button', n_clicks = 0)

x_dd <- dccDropdown(id = 'x_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "age_range")

## HTML divisions ----
header <- htmlDiv(
  list(
    title,
    authors
  ),
  style = list(
    backgroundColor = '#AF33FF', ## COLOUR OF YOUR CHOICE
    textAlign = 'center',
    color = 'white',
    margin = 5,
    marginTop = 0
  )
)

corr_options <- htmlDiv(
  list(
    corr_layout,
    corr_diag,
    corr_label
  ), style = list('display' = 'flex', 'justify-content' = 'space-between')
)

viridis_toggle <- htmlDiv(list( htmlDiv(
  list(viridis_button),
  style = list('display' = 'flex', 'justify-content' = 'flex-end')
),htmlBr()))

theme_dropdown <- htmlDiv(
  list(
    htmlLabel("Select a theme for all the plots:"),
    theme_dd,
    htmlBr()
  )
)

colour_dropdown <- htmlDiv(
  list(
    htmlLabel("Select the variable for colour breakdown of all the plots:"),
    feat_dd,
    htmlBr()
  )
)

xaxis_dropdown <- htmlDiv(
  list(
    htmlLabel("Select the x-axis for the distribution plot:"),
    x_dd,
    htmlBr()
  )
)

reset_button <- htmlDiv(
  list(
    reset
  ),
  style = list('display' = 'flex', 'justify-content' = 'flex-end')
)

master_options <- htmlDiv(
  list(
    reset_button,
    htmlBr(),
    viridis_toggle,
    theme_dropdown,
    colour_dropdown,
    xaxis_dropdown
  )
)


## Create Dash instance ----

app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

## Specify App layout -----
app$layout(
  htmlDiv(
    list(
      ### Add components here
      header,
      master_options,
      age_plot,
      htmlBr(),
      facet_plot,
      htmlBr(),
#      stacked_plot,
 #     htmlBr(),
      corr_options,
      corr_plot
    )
  )
)

## App Callbacks ----
app$callback(
  output = list(id = 'age', property='figure'),
  params = list(input(id = 'x_dd', property = 'value'),
                input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='on'),
                input(id = 'themes', property='value'),
                input(id = 'reset_button', property = 'n_clicks')),
  function(xaxis,breakdown, viridis, theme, clicks) {
    if (clicks > 0 ) {
      make_age_plot()
    } else {
      make_age_plot(xaxis, breakdown, viridis, theme)
    }
  }
)

app$callback(
  output = list(id = 'facet', property='figure'),
  params = list(input(id = 'feat_dd', property='value'),
                input(id = 'viridis_button', property='on'),
                input(id = 'themes', property='value'),
                input(id = 'reset_button', property = 'n_clicks')),
  function(breakdown, viridis, theme, clicks) {
    if (clicks > 0) {
      make_facet_plot()
    } else {
      make_facet_plot(breakdown, viridis, theme)
    }
  }
)

app$callback(
  output = list(id = 'corr', property = 'figure'),
  params = list(input(id = 'layout_button', property='value'),
                input(id = 'diagonal_toggle', property = 'on'),
                input(id = 'viridis_button', property='on'),
                input(id = 'label_toggle', property='on'),
                input(id = 'themes', property='value'),
                input(id = 'reset_button', property = 'n_clicks')),
  function(layout, diag, viridis,label,theme, clicks) {
    if (clicks > 0 ) {
      make_cor_plot()
    } else {
    make_cor_plot(layout,diag,viridis,label, theme)
    }
  }
)



# app$callback(
#   output = list(id = 'label_toggle', property = 'on'),
#   params = list(input(id = 'reset_button', property='n_clicks')),
#   function(clicks) {
#     if (clicks > 0 ) {
#       # reset the label_toggle property 'on' = FALSE
#     }
#   }
# )

## Run app ----
app$run_server(debug=TRUE)

# command to add dash app in Rstudio viewer:
# rstudioapi::viewer("http://127.0.0.1:8050")

## TO DO -----
# add reset button
# organize into tabs
# organize plots into a layout
# add sidebars for selections, etc