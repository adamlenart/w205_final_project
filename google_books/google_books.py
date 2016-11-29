import sys
import os
import requests
import pandas as pd

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
    
    @property
    def totalItems(self):
        '''Total number of search results for the phrase (not used in this version of the script).'''
        return self.result["totalItems"]
    

        
    def extract_information(self):
        '''Get title, ISBN and category for a Google Books query.'''

        result = pd.DataFrame(columns=('title', 'ISBN', 'category'))
        item_counter = 0
        for item in self.result["items"]:
            volume_info = item["volumeInfo"]
            if volume_info.get("industryIdentifiers") is not None and volume_info.get("categories") is not None:
                result.loc[item_counter] = [volume_info["title"] ,volume_info["industryIdentifiers"][0]["identifier"],\
                volume_info["categories"][0]]
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
            books = books.append(new_books,ignore_index=True)
        except KeyError as e:
            break
    return books


# execute from command line
if __name__ == '__main__':
    print get_all_books(sys.argv[1])

