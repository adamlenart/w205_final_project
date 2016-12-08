# ui.R
# 
## 

library(networkD3)
library(plotly)

shinyUI(fluidPage(
  titlePanel("Literal-ly"),
  
  navlistPanel(
    "Visualizations",
    tabPanel("Forecast",
             h3("Forecast popularity of an expression"),
             fluidRow(div(style='padding:10px',
                          column(6,textInput("query","Search expression",value="aboriginal people")),
                          column(6, selectInput("part", label = "Role of first word", 
                                                choices = list("Adjective" = "ADJ", "Adverb" = "ADV", "Noun" = "NOUN", "Verb"="VERB"), 
                                                selected = "ADJ")))),
             fluidRow(div(style='padding:10px',column(4,actionButton("search",label="Search")))),
             hr(),
             div(style='margin-top:80px',plotlyOutput("fcast"))
    ),
    tabPanel("Network",
             h3("Links between categories and decades of publication"),
             "By default, the 5 highest frequency categories are plotted but the data will likely have many more.",
       #      actionButton("var_run",label="CREATE TREE!"),
              fluidRow(div(style='padding:10px,vertical-align:top',
                    column(6,textInput("query","Search expression",value="aboriginal people")),
                    column(2,actionButton("search_book",label="Search")))),
       tags$style(type='text/css', "#search_book { margin-top: 25px}"),
             fluidRow(div(style='padding:10px',
              column(6,
             sliderInput("font","Font",min=1,max=20,value=15)),
               column(6,
             numericInput("filter","Number of most frequent categories to keep",value=5)
             ))),
            hr(),
            sankeyNetworkOutput("network")
    ),
    tabPanel("Treemap",
             h3("Frequency of published books in a given category per decadel"),
             fluidRow(div(style='padding:10px,vertical-align:top',
                          column(6,textInput("query","Search expression",value="aboriginal people")),
                          column(2,actionButton("search_book",label="Search")))),
             tags$style(type='text/css', "#search_book { margin-top: 25px}"),
             fluidRow(div(style='padding:10px',
                          column(6,
                                 sliderInput("font2","Font size",min=1,max=20,value=15)),
                          column(6,
                                 numericInput("filter2","Number of most frequent categories to keep",value=10)
                          ))),
                      hr(),
                      plotOutput("treemap")
    ),
    tabPanel("Ratings",
             h3("Ratings of books by categories"),
             fluidRow(div(style='padding:10px,vertical-align:top',
                          column(6,textInput("query","Search expression",value="aboriginal people")),
                          column(2,actionButton("search_book",label="Search")))),
             tags$style(type='text/css', "#search_book { margin-top: 25px}"),
             fluidRow(div(style='padding:10px',
           #               column(6,
           #                       sliderInput("font3","Font size",min=1,max=20,value=15)),
                          column(6,
                                 numericInput("filter3","Number of most frequent categories to keep",value=5)
                          ))),
             hr(),
             plotlyOutput("boxplot")
             ), # close ratings tab
    tabPanel("Kibana",
             fluidRow(
               htmlOutput("frame"))
             ) #close Kibana tab
  )))
  


