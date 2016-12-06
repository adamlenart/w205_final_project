from pyspark.sql.types import *
from pyspark import SparkContext
from pyspark import HiveContext
#from pyspark.sql import SparkSession
#spark = SparkSession.builder.master("yarn").appName("my app").enableHiveSupport().getOrCreate()
import googlebooks
api = googlebooks.Api()


result = api.list('q:computer science', maxResults=40,langRestrict='en')
index = 0
book_list = list()
while result is not None:
#while index < 40:
    try:
        for i in range(len(result["items"])):
            if result["items"][i]["volumeInfo"].get("industryIdentifiers") is not None and result["items"][i]["volumeInfo"].get("categories") is not None:
                #print result["items"][i]["volumeInfo"]["title"] ,result["items"][i]["volumeInfo"]["industryIdentifiers"][0]["identifier"] ,\
                #      result["items"][i]["volumeInfo"]["categories"][0]
                book_list.append((result["items"][i]["volumeInfo"]["title"] ,result["items"][i]["volumeInfo"]["industryIdentifiers"][1]["identifier"] ,\
                      result["items"][i]["volumeInfo"]["categories"][0], result["items"][i]["volumeInfo"]["averageRating"]))
        index += 40 
        result = api.list('q:computer science', maxResults=40)
    except:
        break
print len(book_list)

sc = SparkContext()
sqlContext = SQLContext(sc)
hive_context = HiveContext(sc)
#sc = HiveContext(sc1)
#sqlContext = HiveContext(sc)
#books = sc.parallelize(book_list)
schema = StructType([
    StructField("Title", StringType(), True),
    StructField("isbn13", StringType(), True),
    StructField("Category", StringType(), True),
    StructField("Rating", StringType(), True)
])

#DF = sqlContext.createDataFrame(books,schema)
DF = hive_context.createDataFrame(book_list,schema)
DF.registerTempTable('google_books_temp')
#results = sqlContext.sql('SELECT * FROM google_books_temp limit 10')
results = hive_context.sql('SELECT * FROM google_books_temp limit 10')
#results = sqlContext.sql('SELECT * FROM good_reads limit 10')
#results.show()
hive_context.sql("DROP TABLE IF EXISTS google_books")
hive_context.sql("CREATE TABLE google_books AS SELECT * FROM google_books_temp")

good_reads = hive_context.table("default.good_reads")
good_reads.registerTempTable("good_reads_temp")
hive_context.sql("select * from good_reads_temp").show()
#new = DF.join(good_reads, DF.isbn13 == good_reads.isbn13, joinType='left_outer')
new = hive_context.sql('SELECT * FROM google_books INNER JOIN good_reads_temp ON google_books.isbn13 = good_reads_temp.isbn13')
