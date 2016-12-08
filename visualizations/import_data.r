library(dplyr)
library(RPostgreSQL)


get_data <- function() {
  my_db <- src_postgres(
    dbname = "literally",
    host = "literally-03.cst8duvjneqw.us-east-1.rds.amazonaws.com",
    user = "dbadmin",
    password = "password"
  )
  
  
  
  #postgres@karl560:/var/lib/postgresql/9.6/postgres_dump$ psql --host literally-03.cst8duvjneqw.us-east-1.rds.amazonaws.com --port 5432 --username dbadmin --dbname literally
  #Password for user dbadmin:
  #  psql (9.6.1, server 9.5.4)
  #SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
  #Type "help" for help.
  
  #literally=> \dt
  #List of relations
  #Schema |         Name         | Type  |  Owner
  #--------+----------------------+-------+---------
  #  public | aboriginal           | table | dbadmin
  #  public | aboriginal_aggregate | table | dbadmin
  # public | aboriginal_top_10    | table | dbadmin
  # public | aboriginal_rating    | table | dbadmin
  # public | abo_fcast          | table   | dbadmin
  #(5 rows)
  
  aboriginal_data <- my_db %>% tbl("aboriginal")
  
  data <- aboriginal_data %>%
    rename(source=category,target=decade) %>% group_by(source,target) %>%
    summarize(value=n()) %>% as.data.frame() 
  
  rating_data <- my_db %>% tbl("aboriginal_ratings") %>% as.data.frame()
  fcast_data <- my_db %>% tbl("abo_fcast") %>% as.data.frame()
  return(list(data,rating_data,fcast_data))
}

