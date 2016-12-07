# ui.R
# 
## 

library(networkD3)

shinyUI(fluidPage(
  titlePanel("Literally"),
  
  navlistPanel(
    "Visualizations",
    tabPanel("Forecast",
             h3("Forecast popularity of an expression"),
             h4("Search term: aboriginal people")
    ),
    tabPanel("Network",
             h3("Links between categories and decades of publication"),
             h4("Search term: aboriginal people"),
             "By default, the 5 highest frequency categories are plotted but the data will likely have many more.",
       #      actionButton("var_run",label="CREATE TREE!"),
             fluidRow(div(style='padding:10px',
              column(6,
             sliderInput("font","Font",min=1,max=20,value=15)),
               column(6,
             numericInput("filter","Number of most frequent categories to keep",value=5)
             )),
            hr(),
            sankeyNetworkOutput("network")
    )),
    tabPanel("Treemap",
             h3("Frequency of published books in a given category per decadel"),
             h4("Search term: aboriginal people"),
             fluidRow(div(style='padding:10px',
                          column(6,
                                 sliderInput("font2","Font size",min=1,max=20,value=15)),
                          column(6,
                                 numericInput("filter2","Number of most frequent categories to keep",value=10)
                          )),
                      hr(),
                      plotOutput("treemap")
    ))
  )))
  
  


