# ui.R
# 
## 
shinyUI(fluidPage(
  titlePanel("Literally"),
  
  navlistPanel(
    "Visualizations",
    tabPanel("Network",
             h3("Network of categories and decades of publication"),
             "Double click on the plot to zoom and click on a node to highlight it.",
       #      actionButton("var_run",label="CREATE TREE!"),
             fluidRow(div(style='padding:10px',
              column(6,
             sliderInput("font","Font",min=1,max=20,value=10)),
               column(6,
             numericInput("filter","Number of most frequent categories to keep",value=NA)
             )),
            hr(),
            sankeyNetworkOutput("network")
    )),
    tabPanel("Treemap",
             h3("This is the second panel"),
             fluidRow(div(style='padding:10px',
                          column(6,
                                 sliderInput("font2","Font",min=1,max=20,value=10)),
                          column(6,
                                 numericInput("filter2","Number of most frequent categories to keep",value=NA)
                          )),
                      hr(),
                      plotOutput("treemap")
    )),
    tabPanel("Third",
             h3("This is the third panel")
    )
  )))
  
  


