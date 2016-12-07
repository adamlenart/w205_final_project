# server.R
library(networkD3)
library(treemap)

source("/home/adam/Documents/MIDS/W205/project/shiny-literally/import_data.r")

get_links <- function(keep_n_cats,data) {
  foo <- transform_data(keep_n_cats,data)
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


transform_data <- function(keep_n_cats,network_data) {
if(is.na(keep_n_cats)==FALSE) {
  frequent_categories <- network_data %>% group_by(source) %>% summarize(total=sum(value)) %>% top_n(keep_n_cats)
  network_data <- network_data %>% inner_join(frequent_categories)
}
  return(network_data)
}


network_data = get_data()

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
  	 
  	)


  
  }) # close shiny server




