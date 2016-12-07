import sys
import os
import requests
from pyspark.sql import HiveContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark import SparkContext
from pyspark import HiveContext


# as Google limits the API results to 40, we need to call the GoogleBooksQuery multiple times to get all of the results.
# The get_all_books() function should do that.
class GoogleBooksQuery():
    '''A Google Books Query queries the Google Books API '''
    # count number of instances
    count = 0
    
    # as there is an upper limit of daily requests sent to the Google API, rather than wasting an extra call just to get
    # the number of total results, let the class already return the results and keep track how many times it was called
    def __init__(self,phrase,maxResults=40):
        '''A GoogleBooksQuery has a url request, the json result of the request and the number of times the query was
           instantiated.
         
        Parameters:
        -----------
        phrase: string, the queried expression on Google Books
        maxResults: int between 1 and 40, the maximum number of results the query should return.
        '''

        self.r = requests.get(url="https://www.googleapis.com/books/v1/volumes", params={"q":phrase,
                                        "maxResults":maxResults,"startIndex":GoogleBooksQuery.count*maxResults})
        self.result = self.r.json()
        GoogleBooksQuery.count += 1
    
      
    def extract_information(self):
        '''Get title, ISBN and category for a Google Books query.'''

        #result = pd.DataFrame(columns=('title', 'ISBN', 'category'))
        result = list()
        item_counter = 0
        for item in self.result["items"]:
            volume_info = item["volumeInfo"]
            if volume_info.get("industryIdentifiers") is not None and volume_info.get("categories") is not None and \
               volume_info.get("averageRating") is not None:
                #print volume_info["averageRating"]
                result.append((volume_info["title"] ,volume_info["industryIdentifiers"][0]["identifier"],\
                volume_info["categories"][0], volume_info["averageRating"]))
                item_counter += 1
        return result
                
def get_all_books(phrase):
    '''Returns all of the results of a Google Books query.
    Parameters:
    -----------
    phrase: query Google Books for phrase
    Returns:
    --------
    A pandas dataframe containing title, ISBN and category as columns and books as rows
    '''
    googlebook = GoogleBooksQuery(phrase)
    books = googlebook.extract_information()
    while True:
        try:
            googlebook = GoogleBooksQuery(phrase)
            new_books = googlebook.extract_information()
            books.extend(new_books)
        except KeyError as e:
            break
    return books

def create_google_books_table(hive_context, book_list):
    '''Function used to create a SQL table called google_books based on the query phrase
       We store the title, isbn13, category and rating'''

    schema = StructType([
        StructField("Title", StringType(), True),
        StructField("isbn13", StringType(), True),
        StructField("Category", StringType(), True),
        StructField("Rating", StringType(), True)
    ])

    DF = hive_context.createDataFrame(book_list,schema)
    DF.registerTempTable('google_books_temp')
    results = hive_context.sql('SELECT * FROM google_books_temp limit 10')
    hive_context.sql("DROP TABLE IF EXISTS google_books")
    hive_context.sql("CREATE TABLE google_books AS SELECT * FROM google_books_temp")
    return 

def merge_google_books_good_reads(hive_context):
    """Merge the good_reads table and google_books table with the common key as isbn13.
       We average the ratings from the 2 tables"""
 
    good_reads = hive_context.table("default.good_reads")
    good_reads.registerTempTable("good_reads_temp")
    #hive_context.sql("select * from good_reads_temp").show()
    hive_context.sql("DROP TABLE IF EXISTS query_bigram_result")
    hive_context.sql('CREATE TABLE query_bigram_result AS SELECT google_books.title, google_books.isbn13, google_books.category, AVG(CASE WHEN good_reads_temp.rating > 0 THEN (google_books.rating + good_reads_temp.rating)/2 ELSE google_books.rating END) as rating FROM google_books LEFT JOIN good_reads_temp ON google_books.isbn13 = good_reads_temp.isbn13 GROUP BY google_books.title,google_books.isbn13, google_books.category')
    merged_table = hive_context.sql('SELECT * from query_bigram_result')
    merged_table.show()
    return

# execute from command line
if __name__ == '__main__':
    book_list = get_all_books(sys.argv[1])
    sc = SparkContext()
    sqlContext = SQLContext(sc)
    hive_context = HiveContext(sc)
    create_google_books_table(hive_context,book_list) 

    merge_google_books_good_reads(hive_context)
