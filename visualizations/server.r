# server.R
library(networkD3)
library(treemap)
library(plotly)

# define auxiliary functions

# functions for downloading data
source("/home/adam/Documents/MIDS/W205/project/shiny-literally/import_data.r")

# kibana src
kibana_src <- "https://search-literal-ly-wtvk5wwjhvhyxm2sqotawqxhfi.us-east-1.es.amazonaws.com/_plugin/kibana/#/dashboard/literal-ly?embed&_a=(filters:!(),panels:!((col:1,id:Rating-per-category,row:4,size_x:12,size_y:4,type:visualization),(col:1,id:Average-Rating,row:1,size_x:6,size_y:3,type:visualization),(col:1,id:Query-counter,row:8,size_x:3,size_y:3,type:visualization),(col:7,id:Query-string,row:1,size_x:6,size_y:3,type:visualization),(col:4,id:Timeline,row:8,size_x:9,size_y:3,type:visualization)),query:(query_string:(analyze_wildcard:!t,query:'*')),title:literal-ly)&_g=(refreshInterval:(display:'10%20seconds',pause:!f,section:1,value:10000),time:(from:now-15s,mode:relative,to:now))"

# build network data
get_links <- function(keep_n_cats,data,source="source",target="target",value="value") {
  foo <- transform_data(keep_n_cats,data, value=value)
  nodes <- data.frame(name=unique(c(foo$source,foo$target)))
  links<- data.frame(source=match(foo$source,nodes$name)-1,
                     target=match(foo$target,nodes$name)-1,
                     value=foo$value)
  return(links)
}

get_nodes <- function(keep_n_cats,data) {
  foo <- transform_data(keep_n_cats,data)
  sources <- unique(foo$source)
  targets <- unique(foo$target)
  nodes <- data.frame(name=c(sources,targets),
                      groups=c(rep(0,length(sources)),rep(1,length(targets))))
  return(nodes)
}


transform_data <- function(keep_n_cats,data,value="value") {
  if(value=="value") {
     if(is.na(keep_n_cats)==FALSE) {
        frequent_categories <- data %>% group_by(source) %>% summarize(total=sum(value)) %>% top_n(keep_n_cats)
        network_data <- data %>% inner_join(frequent_categories)
     }
  }
  if(value=="rating") {
    if(is.na(keep_n_cats)==FALSE) {
      frequent_categories <- data %>% group_by(category) %>% summarize(total=n()) %>% top_n(keep_n_cats)
      network_data <- data %>% inner_join(frequent_categories)
    } 
  }  
  return(network_data)
}

# get data
db_data <- get_data()
network_data = db_data[[1]]
rating_data = db_data[[2]] # there are fewer ratings than books, so it is better to keep them separately

# define server side process
shinyServer(
  function(input, output, session) {
   

    output$network <- renderSankeyNetwork(
  #    keep_n_cats <- reactive({input$filter})y
  	  sankeyNetwork(Links=get_links(input$filter,network_data),
  	                Nodes=get_nodes(input$filter,network_data),
  	                Source="source",Target="target",
  	                Value="value",NodeID="name",fontSize=input$font)
    ) # close render sankey network,
  	  
  	output$treemap <- renderPlot(
  	     treemap(transform_data(input$filter2,network_data),fontsize.labels=input$font2,
  	             index=c("source","target"),vSize="value",title="") 
  	 
  	) # close the treemap
  	
  	output$boxplot <- renderPlotly(
  	  plot_ly(transform_data(input$filter3,rating_data,value="rating"), y=~rating, x=~category,type="box")   
  	    
  	)
   # add kibana dashboard
  	output$frame <- renderUI({
  	  input$Member
  	  kibana <- tags$iframe(src=kibana_src, height=800, width=600)
  	  print(kibana)
  	  kibana
  	})

  
  }) # close shiny server




