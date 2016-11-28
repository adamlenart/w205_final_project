# forecasting and plotting libraries
library(forecast)
library(ggplot2)

# Bigram to query
bigram <- "Aboriginal_ADJ people" 

# read from Hive
hiveContext <- sparkRHive.init(sc)
data <- sql(hiveContext,"SELECT * FROM default.bigram") 
data_phrase <- collect(filter(data,data$phrase==bigram))

# perform forecast, save results as a png 
get_forecast <- function(data=data_phrase,year_start=1980,year_end=2020,save_plot=TRUE) {
    data$year <- as.numeric(as.character(data$year))
    dat <- subset(data,year>=year_start)
    best_fit <- auto.arima(dat$match_count,xreg=dat$year)
    fcast <- forecast(best_fit, h=year_end-max(dat$year), xreg=data.frame(year=(max(dat$year)):year_end))
    if(save_plot) {
        autoplot(fcast)+scale_y_continuous("Frequency\n") + 
           scale_x_continuous("Year",breaks=seq(0,(year_end-year_start),by=5),label=seq(year_start,year_end,by=5))+
           ggtitle(bigram)
        ggsave(paste("forecast",format(Sys.time(), "%Y%m%d-%H%M%S"),".png",sep=""))
    }
    return(fcast)
}

get_forecast()

