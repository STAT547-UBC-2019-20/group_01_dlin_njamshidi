# data <- read.csv(here(processed_data))

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
suppressPackageStartupMessages(library(broom))


### load data
data <- readRDS(here("data","processed","processed_data.rds"))

### lm variable key
lmvarKey <- tibble(label = c("Age", "Sex", "BMI", "Children", "Smoker", "Region"),
                   value = c("age", "sex", "bmi", "children", "smoker", "region"),
                   default = c(74,"male",30.4,5,"no","northeast"),
                   default_type = c(TRUE,FALSE,TRUE,TRUE,FALSE,FALSE)
                   )



## defining functions ----

### linear model function
linear_model <- function(lm_variables=c('age', 'sex','bmi')){
  model <-
    lm(as.formula(paste("charges ~ ", paste(lm_variables, collapse= " + "))), data = data)
}
### default model
model <- linear_model()

### rsquarred markdown function
rsquared <- function(model){
  paste0("Linear regression r-squared value is **",round(glance(model)[1][[1]],3),"**.")
}

### lm plot function
lm_plot <- function(model){
  p4 <- suppressMessages(left_join(augment(model),data)) %>% 
    ggplot(aes(x = .fitted, y = charges, text = paste('</br>Age: ', age,
                                                       '</br>Sex: ',sex,
                                                       '</br>BMI: ',bmi,
                                                       '</br>Children: ',children,
                                                       '</br>Smoker: ',smoker,
                                                       '</br>Region: ',region,
                                                       '</br></br>Charges:', round(charges,-1),'$',
                                                       '</br>Estimated Charges:', round(.fitted,-1),'$'))) +
    geom_point() +
    geom_abline(slope = 1, colour = "blue") +
    coord_fixed() +
    theme_bw() +
    labs(title = "Real vs. Fitted",
         x = "Fitted Values", y = "Real Values") +
    theme(plot.title = element_text(hjust = 0.5, face = "plain"))+
    theme(axis.text.x = element_text(
      angle = 45,
      vjust = 1,
      size = 12,
      hjust = 1
    ),
    axis.text.y = element_text(size =12))
    p4
    ggplotly(p4,tooltip = c("text"),height = 640,width = 320)
}

### lm table function
lm_table <- function(model){
  tidied <- tidy(model)
  table <- plot_ly(
    type = 'table',
    header = list(
      values = map_chr(names(tidied),~paste0('<b>',.,'<b>')),
      line = list(color = '#506784'),
      fill = list(color = '#119DFF'),
      align = c('left','center'),
      font = list(color = 'white', size = 12)
    ),cells = list(
      values = t(tidied),
      line = list(color = '#506784'),
      fill = list(color = c('#25FEFD', 'white')),
      align = c('left', 'center'),
      font = list(color = c('#506784'), size = 12)
    )
  )
  table
}

### predict function
lm_predict <- function(p_model=model,newdata=data.frame(age=74,sex="male",bmi=30.4)){
  paste0(round(predict.lm(p_model,newdata),-1),' $')
}

## Defining components ----

### markdown for variable selection
lm_variables_markdown <- dccMarkdown('**Variables to be used in the linear model**')

### variable checklist
lm_variables <- dccChecklist(
  id = 'lm-checklist',
  options = map(1:nrow(lmvarKey), function(i) {
    list(
      label = lmvarKey$label[i],
      value = lmvarKey$value[i],
      disabled = ifelse(lmvarKey$value[i] %in% c('age', 'sex', 'bmi'), TRUE , FALSE)
    )
  }),
  value = c('age', 'sex', 'bmi'),
  labelStyle=list('display'= 'inline-block')
  # style = list('width'='100%')
)


### rsquarred markdown component
lm_result <- dccMarkdown(
  id='lm-markdown',
  children = rsquared(model),
  style = list('display' = 'flex', 'justify-content'='center')
    )

### lm plot component
plot4 <- dccGraph(id='lm-plot',figure = lm_plot(model))

### lm table component
table <- dccGraph(id='lm-table', figure = lm_table(model))

### predict introduction markdown component
predict_markdown <-
  dccMarkdown(
    id = 'predict-markdown',
    children = "Here is the estimate of Mr. Trump's medical expenses based on the selected model. How much medical expenses would you be incurred based on the selected model? Enter you information below:",
    style = list('display' = 'flex', 'justify-content' = 'center')
  )

### predict age component
predict_Age <-
  dccDropdown(
    id = 'predict_age',
    options = map(1:90, function (i)
      list(
        label = lubridate::year(Sys.Date()) - i, value = i
      )),
    # value = "74",
    disabled = FALSE
    )

### predict sex component
predict_Sex <-
  dccDropdown(
    id = 'predict_sex',
    options = map(1:2, function (i)
      list(
        label = c('Female', 'Male')[i],
        value = c('female', 'male')[i]
      )),
    # value = "male",
    disabled = FALSE
  )

### predict BMI component
predict_BMI <- dccInput(
  id='predict_bmi',
  # placeholder = "Trump's BMI is 30.4",
  type = 'number',
  # value = "30.4",
  disabled = FALSE,
  style=list('width'='80%')
)

### predict Children component
predict_Children <-
  dccDropdown(
    id = 'predict_children',
    options = map(1:11, function (i)
      list(
        label = i-1,
        value = i-1
      )),
    # value = 5,
    disabled = FALSE
  )

### predict smoker component
predict_Smoker <-
  dccDropdown(
    id = 'predict_smoker',
    options = map(1:2, function (i)
      list(
        label = c('Yes', 'No')[i],
        value = c('yes', 'no')[i]
      )),
    # value = "no",
    disabled = FALSE
  )

### predict region component
predict_Region <-
  dccDropdown(
    id = 'predict_region',
    options = map(1:4, function (i)
      list(
        label = c('North East', 'North West','South East','South West')[i],
        value = c('northeast', 'northwest','southeast','southwest')[i]
      )),
    # value = "northeast",
    disabled = FALSE
  )


### predict markdown component
predict_result <-
  dccMarkdown(
    id = 'predict_result',
    children = lm_predict(model,data.frame(age=74,sex="male",bmi=30.4)),
    # children = "khar",
    style = list(
      'display' = 'flex',
      'justify-content' = 'center',
      'margin'=4
    )
  )

## defining html divs ----

Div_variables <- htmlDiv(
  list(
    lm_variables
    # htmlBr(),
    
   ), style = list('flex-basis' = '75%','margin' = 10, 'display' = 'flex', 'align-items' = 'center', 'flex-direction' = 'row')
)


Div_variables_markdown <- htmlDiv(
  list(
    lm_variables_markdown,
    dccMarkdown("### **:**")
  ),
  style = list('flex-basis' = '25%','flex-direction' = 'row','align-items' = 'center','margin'=10,'display' = 'flex')
)

Div_variables_2 <- htmlDiv(
  list(
    Div_variables_markdown,
    Div_variables
    # htmlBr(),
    
  ), style = list('display' = 'flex', 'align-items' = 'center', 'flex-direction' = 'row', 'justify-content'='center','width' = '80%','border-style'='solid')
)

Div_variables_3 <- htmlDiv(
  list(
    Div_variables_2,
    htmlBr()
    ),
  style = list('display' = 'flex', 'align-items' = 'center', 'flex-direction' = 'column', 'justify-content'='center')
)


Div_stats <- htmlDiv(
  list(
    lm_result,
    table
  ), style = list('display' = 'flex', 'flex-direction' = 'column','flex-basis' = '70%')
)

Div_lm_result <- htmlDiv(
  list(
    Div_stats,
    plot4
  ), style = list('display' = 'flex','align-items' = 'center', 'flex-direction' = 'row')
)


Div_p_Age <- htmlDiv(
  list(
    dccMarkdown(id='p-m-1',children = 'Date of Birth:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_Age
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%','align-items' = 'flex-start')
)



Div_p_Sex <- htmlDiv(
  list(
    dccMarkdown(id='p-m-2',children = 'Sex:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_Sex
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%')
)

Div_p_BMI <- htmlDiv(
  list(
    dccMarkdown(id='p-m-3',children = 'BMI:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_BMI
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%')
)

Div_p_Children <- htmlDiv(
  list(
    dccMarkdown(id='p-m-4',children = 'Number of children:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_Children
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%')
)

Div_p_Smoker <- htmlDiv(
  list(
    dccMarkdown(id='p-m-5',children = 'Frequent smoker:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_Smoker
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%')
)

Div_p_Region <- htmlDiv(
  list(
    dccMarkdown(id='p-m-6',children = 'Region:',style = list('display' = 'flex', 'justify-content'='left')),
    predict_Region
  ),
  style = list('display' = 'flex', 'flex-direction' = 'column','margin'=5,'width' = '12.5%')
)

Div_p_button <- htmlButton("submit", id = 'predict_button', n_clicks = 0, style = list('display' = 'flex', 'flex-direction' = 'column','margin'=50,'height' = '100%'))


Div_p_result <- htmlDiv(
  list(
    predict_result
  ),
  style = list('display' = 'flex','align-items' = 'center','border-style' = 'ridge','border-color' = 'green')
)


Div_p_var <- htmlDiv(
  list(
    Div_p_Age,
    Div_p_Sex,
    Div_p_BMI,
    Div_p_Children,
    Div_p_Smoker,
    Div_p_Region,
    Div_p_button
  ),
  style = list('display' = 'flex','align-items' = 'space-between', 'flex-direction' = 'row','margin'=5)
)

Div_p <- htmlDiv(
  list(
    predict_markdown,
    Div_p_var,
    Div_p_result,
    htmlBr()
  ),
  style = list('display' = 'flex','align-items' = 'center', 'flex-direction' = 'column','margin'=5,'border-style'='double')
)

## Starting new dash app ----

app <- Dash$new()

app$layout(htmlDiv(
  list(
    Div_variables_3,
    Div_lm_result,
    Div_p
    )
  )
)

## callbacks ----

### callback for checklist limit
app$callback(output = list(id = 'lm-checklist', property = 'options'),
             params = list(input(id = 'lm-checklist', property = 'value')),
             
             function(variables) {
               # clickData contains $x, $y and $customdata
               # you can't access these by gapminder column name!
               if (length(variables) == 3) {
                 map(1:nrow(lmvarKey), function(i) {
                   list(
                     label = lmvarKey$label[i],
                     value = lmvarKey$value[i],
                     disabled = ifelse(lmvarKey$value[i] %in% variables, TRUE , FALSE)
                   )
                 })
               }
               else{
                 map(1:nrow(lmvarKey), function(i) {
                   list(
                     label = lmvarKey$label[i],
                     value = lmvarKey$value[i],
                     disabled = FALSE
                   )
                 })
               }
             })

### callback for updating model and its results
app$callback(output = list(
  output(id = 'lm-markdown', property = 'children'),
  output(id = 'lm-plot', property = 'figure'),
  output(id = 'lm-table', property = 'figure')
), params = list(input(id = 'lm-checklist', property = 'value')),
function(variables) {
  model <- linear_model(variables)
  return(list(rsquared(model), lm_plot(model), lm_table(model)))
})

### callback for prediction
# app$callback(output = list(id = 'predict_result', property = 'children'),
#              params = list(
#                input(id = 'predict_button', property = 'n_clicks'),
#                state(id='lm-checklist', property = 'value'),
#                state(id = 'predict_age', property = 'value'),
#                state(id = 'predict_sex', property = 'value'),
#                state(id = 'predict_bmi', property = 'value'),
#                state(id = 'predict_children', property = 'value'),
#                state(id = 'predict_smoker', property = 'value')
#              ),
#              function(nclick,vars,age1, sex1, bmi1, children1, smoker1) {
#                if (nclick == 0 ) {
#                  lm_predict("")
#                } else {
#                  sample <- data.frame(age=age1,sex=sex1,bmi=bmi1,children=children1,smoker=smoker1)
#                  lm_predict(linear_model(vars),sample)
#                  # is.na(sample)
#                }
# 
#              })




# app$callback(output = list(id = 'predict_BMI', property = 'value'),
#              params = list(
#                input(id = 'predict_button', property = 'n_clicks')
#              ),
#              function(nclick) {
#                nclick             
#              })
# 
# app$callback(output = list(id = 'predict_result', property = 'children'),
#              params = list(
#                input(id = 'predict_button', property = 'n_clicks')
#                ),
#              function(nclick) {
#                 paste0(nclick)             
#              })



# app$callback(output = list(
#     output(id = 'predict_age', property = 'value'),
#     output(id = 'predict_sex', property = 'value'),
#     output(id = 'predict_bmi', property = 'value'),
#     output(id = 'predict_children', property = 'value'),
#     output(id = 'predict_smoker', property = 'value'),
#     output(id = 'predict_region', property = 'value'),
#     output(id = 'predict_age', property = 'disabled'),
#     output(id = 'predict_sex', property = 'disabled'),
#     output(id = 'predict_bmi', property = 'disabled'),
#     output(id = 'predict_children', property = 'disabled'),
#     output(id = 'predict_smoker', property = 'disabled'),
#     output(id = 'predict_region', property = 'disabled'),
#     output(id = 'Div_p_Age', property = 'style'),
#     output(id = 'Div_p_Sex', property = 'style'),
#     output(id = 'Div_p_BMI', property = 'style'),
#     output(id = 'Div_p_Children', property = 'style'),
#     output(id = 'Div_p_Smoker', property = 'style'),
#     output(id = 'Div_p_Region', property = 'style')
#   ),
#   params = list(input(id='lm-checklist', property = 'value')),
# 
#   function(variables) {
#     clause <- lmvarKey$value %in% variables
#     return(combine(map(1:nrow(lmvarKey), function(i) {
#       ifelse(
#         clause[i] == TRUE,
#         ifelse(
#           lmvarKey$default_type[i] == TRUE,
#           as.numeric(lmvarKey$default[i]),
#           lmvarKey$default[i]
#         ),
#         ''
#       )
#     }),
#     as.list(!clause), map(1:nrow(lmvarKey), function(i) {
#       ifelse(
#         clause[i] == TRUE,
#         list(
#           'display' = 'flex',
#           'flex-direction' = 'column',
#           'margin' = 5,
#           'flex-basis' = '20%'
#         ),
#         list(
#           'display' = 'flex',
#           'flex-direction' = 'column',
#           'margin' = 5,
#           'flex-basis' = '20%',
#           'opacity' = 0.5
#         )
#       )
#     })))
#   }
#   )

# 
# 
app$callback(output = list(id = 'predict_result', property = 'children'),
             params = list(
               input(id = 'predict_button', property = 'n_clicks'),
               state(id='lm-checklist', property = 'value'),
               state(id = 'predict_age', property = 'value'),
               state(id = 'predict_sex', property = 'value'),
               state(id = 'predict_bmi', property = 'value'),
               state(id = 'predict_children', property = 'value'),
               state(id = 'predict_smoker', property = 'value'),
               state(id = 'predict_region', property = 'value')
             ),
             function(nclick,variables,age1, sex1, bmi1, children1, smoker1,region1) {
               if (nclick > 0) {
               sample <- data.frame(age=age1,sex=sex1,bmi=bmi1,children=children1,smoker=smoker1,region=region1)
               clause <- lmvarKey$value %in% variables
               lm_predict(linear_model(variables),sample[clause])
               }else{
                 lm_predict()
               }
               # is.na(sample)


             })

app$callback(output = list(
  output(id = 'predict_age', property = 'value'),
  output(id = 'predict_sex', property = 'value'),
  output(id = 'predict_bmi', property = 'value'),
  output(id = 'predict_children', property = 'value'),
  output(id = 'predict_smoker', property = 'value'),
  output(id = 'predict_region', property = 'value'),
  output(id = 'predict_age', property = 'disabled'),
  output(id = 'predict_sex', property = 'disabled'),
  output(id = 'predict_bmi', property = 'disabled'),
  output(id = 'predict_children', property = 'disabled'),
  output(id = 'predict_smoker', property = 'disabled'),
  output(id = 'predict_region', property = 'disabled')
),
params = list(input(id='lm-checklist', property = 'value')),

function(variables) {
  clause <- lmvarKey$value %in% variables
  return(combine(map(1:nrow(lmvarKey), function(i) {
    ifelse(
      clause[i] == TRUE,
      ifelse(
        lmvarKey$default_type[i] == TRUE,
        as.numeric(lmvarKey$default[i]),
        lmvarKey$default[i]
      ),
      ''
    )
  }),
  as.list(!clause)))
}
)


app$run_server(debug=TRUE)