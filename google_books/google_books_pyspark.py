from pyspark.sql import HiveContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark import SparkContext
from pyspark import HiveContext
#from pyspark.sql import SparkSession
#spark = SparkSession.builder.master("yarn").appName("my app").enableHiveSupport().getOrCreate()
import googlebooks
api = googlebooks.Api()


result = api.list('q:hello world', maxResults=40)
index = 0
book_list = list()
#while result is not None:
while index < 40:
    try:
        for i in range(len(result["items"])):
            if result["items"][i]["volumeInfo"].get("industryIdentifiers") is not None and result["items"][i]["volumeInfo"].get("categories") is not None:
                #print result["items"][i]["volumeInfo"]["title"] ,result["items"][i]["volumeInfo"]["industryIdentifiers"][0]["identifier"] ,\
                #      result["items"][i]["volumeInfo"]["categories"][0]
                book_list.append((result["items"][i]["volumeInfo"]["title"] ,result["items"][i]["volumeInfo"]["industryIdentifiers"][0]["identifier"] ,\
                      result["items"][i]["volumeInfo"]["categories"][0]))
        index += 40
        result = api.list('q:hello world', maxResults=40)
    except:
        break
print len(book_list)

sc = SparkContext()
sqlContext = SQLContext(sc)
#sc = HiveContext(sc1)
#sqlContext = HiveContext(sc)
books = sc.parallelize(book_list)
schema = StructType([
    StructField("Title", StringType(), True),
    StructField("isbn13", StringType(), True),
    StructField("Category", StringType(), True)
])

DF = sqlContext.createDataFrame(books,schema)
#DF.createExternalTable('google_books')
#results = sqlContext.sql('SELECT * FROM google_books limit 10')
#results = sqlContext.sql('SELECT * FROM good_reads limit 10')
DF.show()

