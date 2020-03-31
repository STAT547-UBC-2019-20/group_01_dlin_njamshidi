# author: Diana Lin
# date: March 19, 2020

"This script creates the dashboard corresponding to our exploratory data analysis and linear regression.
Usage: app.R"

# load libraries ----
suppressPackageStartupMessages(library(dash))
suppressPackageStartupMessages(library(dashCoreComponents))
suppressPackageStartupMessages(library(dashHtmlComponents))
suppressPackageStartupMessages(library(dashTable))
suppressPackageStartupMessages(library(dashDaq))
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
                 value = c("_gray", "_bw", "_light", "_dark", "_minimal", "_classic", ""))

make_age_plot <- function(xaxis = "age_range", breakdown = "smoker", viridis = FALSE, theme_select = "_minimal") {
  
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
  
  p1 <- p1 + do.call(paste0("theme",theme_select),list()) + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  
  # if(theme_select == "minimal") {
  #   p1 <- p1 + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "gray") {
  #   p1 <- p1 + theme_gray() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "classic") {
  #   p1 <- p1 + theme_classic() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "light") {
  #   p1 <- p1 + theme_light() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "dark") {
  #   p1 <- p1 + theme_dark() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "bw") {
  #   p1 <- p1 + theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else {
  #   p1 <- p1 + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # }
  
  ggplotly(p1)
}

make_facet_plot <- function(breakdown = "smoker", viridis = FALSE, theme_select = "_minimal") {
  
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
  
  p2 <- p2 + do.call(paste0("theme",theme_select),list()) + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  
  # if(theme_select == "minimal") {
  #   p2 <- p2 + theme_minimal() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "gray") {
  #   p2 <- p2 + theme_gray() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "classic") {
  #   p2 <- p2 + theme_classic() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "light") {
  #   p2 <- p2 + theme_light() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "dark") {
  #   p2 <- p2 + theme_dark() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else if (theme_select == "bw") {
  #   p2 <- p2 + theme_bw() + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # } else {
  #   p2 <- p2 + theme(axis.text = element_text(size = 12), text = element_text(family = "HelveticaNeue"))
  # }
  
  ggplotly(p2)
}

make_cor_plot <- function(layout = "lower", diag = FALSE, viridis = FALSE, labels = TRUE, theme_select = "_minimal"){
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
    ggplot(aes(Var2, Var1, fill = value, text = glue("Var1: {Var2}</br></br>Var2: {Var1}</br>Correlation: {value}"))) +
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
  
  p4 <- p4 + do.call(paste0("theme",theme_select),list()) + theme(axis.text.x = element_text(
    angle = 45,
    vjust = 1,
    size = 12,
    hjust = 1
  ),
  axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue"))
  
  # if(theme_select == "minimal") {
  #   p4 <- p4 + theme_minimal() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else if (theme_select == "gray") {
  #   p4 <- p4 + theme_gray() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else if (theme_select == "classic") {
  #   p4 <- p4 + theme_classic() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else if (theme_select == "light") {
  #   p4 <- p4 + theme_light() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else if (theme_select == "dark") {
  #   p4 <- p4 + theme_dark() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else if (theme_select == "bw") {
  #   p4 <- p4 + theme_bw() + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # } else {
  #   p4 <- p4 + theme(axis.text.x = element_text(
  #     angle = 45,
  #     vjust = 1,
  #     size = 12,
  #     hjust = 1
  #   ),
  #   axis.text.y = element_text(size =12), text = element_text(family = "HelveticaNeue")) 
  # }
    
  ggplotly(p4, tooltip = c("text"))
}

## Assign components to variables ----

### title of the page
title <- htmlH1("Factors Affecting Medical Expenses")

### subtitle of the page
authors <- htmlH4("By Diana Lin & Nima Jamshidi")

### bar plot component
age_plot <- dccGraph(id = 'age', figure = make_age_plot())

### colour dropdown menu component
feat_dd <- dccDropdown(id = 'feat_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "smoker")

### faceted plot component
facet_plot <- dccGraph(id = 'facet', figure = make_facet_plot())

### viridis toggle component
viridis_button <- daqBooleanSwitch(id = 'viridis_button',
                                   on = FALSE,
                                   label = "Viridis Toggle",
                                   labelPosition = "top")

### correlation plot component
corr_plot <- dccGraph(id = 'corr', figure = make_cor_plot())

### correlation plot layout radio menu
corr_layout <- dccRadioItems(id = 'layout_button',
                             options = list(
                               list(label = "Lower", value = "lower"),
                               list(label = "Upper", value = "upper"),
                               list(label = "Full", value = "full")
                             ),
                             value = "lower")

### correlation plot show diagonal toggle
corr_diag <- daqBooleanSwitch(id = 'diagonal_toggle',
                              on = FALSE)

### correlation plot show labels toggle
corr_label <- daqBooleanSwitch(id = 'label_toggle',
                               on = TRUE)

### dropdown menu for theme component
theme_dd <-
  dccDropdown(
    id = 'themes',
    options = map(1:nrow(themes), function (i)
      list(label = themes$label[i], value = themes$value[i])),
    value = "_minimal"
  )

### reset button component
reset_button <- htmlButton("Reset", id = 'reset_button', n_clicks = 0)

### x-axis dropdown menu component
x_dd <- dccDropdown(id = 'x_dd', options = map(1:nrow(vars), function (i) list(label=vars$label[i], value=vars$value[i])), value = "age_range")

### Markdown table component
data_table <- dccMarkdown("
Variable | Type | Description
---------|------|---------------
Age | integer | the primary beneficiary's age in years
Sex | factor | the beneficiary's sex: `female` or `male`
BMI | double | the beneficiary's Body Mass Index, a measure of their body fat based on height and weight (measured in kg/m<sup>2</sup>), an ideal range of 18.5 to 24.9
Children | integer | the number of dependents on the primary beneficiary's insurance policy
Smoker | factor | whether or not the beneficiary is a smoker: `yes` or `no`
Region | factor | the beneficiary's residential area in the USA: `southwest`, `southeast`, `northwest`, or `northeast`
Charges | double | the monetary charges the beneficiary was billed by health insurance", dangerously_allow_html = TRUE)

## HTML divisions ----

### Header of the dashboard, consistent on every page
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

### Research question div
research_question <-
  htmlDiv(list(
    htmlH3("Research Question"),
    dccMarkdown(
      "In this study, we are analyzing the data to find a relationship between the features and the amount of insurance cost. Does having an increased BMI increase your insurance costs? What about age? Number of dependents? Smoking status? Are certain areas of the USA associated with higher insurance costs? In order to answer the questions above we're planning to perform a linear regression analysis and plot the regression line and relevant variables. The variables need to be normalized before performing the regression analysis. A detailed final report can be found [here](https://stat547-ubc-2019-20.github.io/group_01_dlin_njamshidi/milestone3.html)."
    )
  ), style = list('margin-right' = 10, 'margin-left' = 10))

### Data description div
data_desc <- htmlDiv(
  list(
    htmlH3("Data Description"),
    htmlP("This dataset explains the medical insurance costs of a small sample of the USA population. Each row corresponds to a beneficiary. Various metadata was recorded as well. The columns (except the last one) in this dataset correspond to metadata, where the last column is the monetary charges of medical insurance. Here are the possible values for each of the columns:")
  ), style = list('margin-left' = 10, 'margin-right' = 10)
)

### Table Div
final_table <- htmlDiv(
  list(
    data_table
  ), style = list('margin-bottom' = 20)
)

### Combined Div of Research Question and Data Description
information <- htmlDiv(
  list(
    htmlDiv(
      list(
        research_question,
        data_desc
      ),
      style = list('display' = 'flex', 'justify-content' = 'center')
  ), htmlDiv(
    list(
      final_table
    ),style = list('display' = 'flex', 'justify-content' = 'center')
  )
)
)

### Toggles on both tags div 
master_toggles <- htmlDiv(
  list(
    reset_button,
    htmlBr(),
    viridis_button
  ), style = list('margin' = 10, 'display' = 'flex', 'align-items' = 'flex-end', 'flex-direction' = 'column')
)

# tab1 sidebar div
tab1_sidebar_top <- htmlDiv(
  list(
    htmlH5("Sidebar"),
    htmlP("Select the breakdown for both plots:"),
    feat_dd,
    htmlBr(),
    htmlP("Select the x-axis for the bar plot: "),
    x_dd
  ),
  style = list('margin-bottom' = 5, 'width' = '60%', 'height' = '50%' , 'display' = 'flex', 'flex-direction' = 'column', 'justify-content' = 'center')
)

### tab1 bar plot div
plot1 <- htmlDiv(
  list(
    age_plot
  ), style = list('width' = '100%', 'height' = '100%')
)

### tab 1 bar plot caption div
plot1_cap <- htmlDiv(
  list(
    htmlH6("Caption:"),
    htmlP("How is the distribution of sex among different age groups? There appears to be more beneficiaries in the 20-60 age range. The biggest difference in the number of beneficiaries from different sex is seen in the 20-30 bracket. What about the distribution of other variables across different age groups? Across smoking status? Use the dropdown menus in the sidebar to investigate!")
  ), style = list('width' = '20%', 'height' = '100%')
)

### tab1 combined barplot + caption div
plot1_full <- htmlDiv(
  list(
    plot1,
    plot1_cap
  ), style = list('margin' = 5, 'display' = 'flex')
)

### tab1 facteted plot div
plot2 <- htmlDiv(
  list(
    facet_plot
  ), style = list('width' = '100%', 'height' = '100%')
)

### tab1 faceted plot caption div
plot2_cap <- htmlDiv(
  list(
    htmlH6("Caption:"),
    htmlP("In order to to check if there is any cluster of data points, we use faceted plot. While the data between regions and sex does not appear to vary much, the smokers vs non-smokers of each facet appear to cluster together, with the non-smokers having an overall lower medical cost.")
  ), style = list('width' = '20%', 'height' = '100%')
)

### tab1 faceted plot + caption combined div
plot2_full <- htmlDiv(
  list(
    plot2,
    plot2_cap
  ), style = list('margin' = 5, 'display' = 'flex')
)

### tab1 combined bar+facet div
two_plots <- htmlDiv(
  list(
    plot1_full,
    htmlBr(),
    plot2_full
  ), style = list('display' = 'flex', 'flex-direction' = 'column')
)

### tab1 top half div (sidebar + 2 plots)
tab1_top_half <- htmlDiv(
  list(
    tab1_sidebar_top,
    two_plots
  ), style = list('display' = 'flex')
)

#33 tab1 bottom sidebar div
tab1_sidebar_bottom <- htmlDiv(
  list(
    htmlP("Select the layout for the correlation plot:"),
    corr_layout,
    htmlBr(),
    htmlP("To show/hide the diagonal of the correlation plot:"),
    corr_diag,
    htmlBr(),
    htmlP("To show/hide the correlation values on the correplation plot:"),
    corr_label
  ),
  style = list('margin-bottom' = 5, 'width' = '60%', 'height' = '50%' , 'display' = 'flex', 'flex-direction' = 'column', 'align-items' = 'flex-start')
)

### tab1 correlation plot div
plot3 <- htmlDiv(
  list(
    corr_plot
  ), style = list('width' = '100%', 'height' = '100%')
  
)

### tab1 correlation plot caption div
plot3_cap <- htmlDiv(
  list(
    htmlH6("Caption:"),
    htmlP("To inspect the data set to see if there is any correlation between the variables, we use a correlation plot. We want to consider charges as our dependent variable, and see how the other factors relate to charges. According to the correlation plot, smoking status and charges has the strongest correlation of 0.79. No high collinearity between independent variables is observed.")
  ), style = list('width' = '20%', 'height' = '100%')
)

### tab1 correlation plot caption div
plot3_full <- htmlDiv(
  list(
    plot3,
    plot3_cap
  ), style = list('margin' = 5, 'display' = 'flex')
)

### tab1 correplation plot combined div
one_plot <- htmlDiv(
  list(
    plot3_full
  ), style = list('display' = 'flex')
)

### tab1 bottom half div: bottom sidebar + corrplot
tab1_bottom_half <- htmlDiv(
  list(
    tab1_sidebar_bottom,
    one_plot
  ), style = list('display' = 'flex')
)

# tab 1 elements
tab1_page <- htmlDiv(
  list(
    master_toggles,
    htmlP("Select a theme for all plots:"),
    theme_dd,
    htmlBr(),
    tab1_top_half,
    tab1_bottom_half
  ), style = list('margin' = 5)
)
  
# tab 2 elements
tab2_page <- htmlDiv(
  list(
    master_toggles,
    htmlP("Select a theme for all plots:"),
    theme_dd,
    htmlBr()
    #### NIMA'S PART ####
  )
)


## Create Dash instance ----
app <- Dash$new(external_stylesheets = "https://codepen.io/chriddyp/pen/bWLwgP.css")

## Specify App layout -----
app$layout(
  header,
  information,
  htmlDiv(
    list(
      # TABS
      dccTabs(id="tabs", value='tab-1', children=list(
        dccTab(label='Exploration', value='tab-1'),
        dccTab(label='Linear Regression', value='tab-2')
      )),
      htmlDiv(id='tabs-content')
    )
  )
)

## App Callbacks ----

### Callback to update the bar plot
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

### Callback to update the faceted plot
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

### Callback to update the correlation plot
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

# Callback to update the tabs as they are clicked
app$callback(
  output = list(id = 'tabs-content', property = 'children'),
  params = list(input(id='tabs', 'value')),
  function(tab) {
    if (tab == 'tab-1') {
      tab1_page
    }
    else if (tab == 'tab-2') {
      tab2_page
    }
  }
)

# How to get the reset the reset button n_clicks to 0?
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