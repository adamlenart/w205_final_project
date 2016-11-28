# Forecasting bigram frequencies
 
First, install R with

    yum install R

then install a bunch of R packages which are the dependencies of the forecast package

    bash install_forecast_dependencies.sh

Finally start sparkR

    $SPARK_HOME/bin/sparkR

and run 
  
    source("sparkr_forecast.r")

The command line version

    spark-submit sparkr_forecast.r

returns a Java class not found error...probably we could try to run R from Python with the r2py package.
