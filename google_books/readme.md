# Query Google Books API for a phrase

Running 
    
    python google_books.py "my phrase" "my_csv_file.csv"

returns the search results as a pandas data frame with title, ISBN and category columns. The first argument is the queried phrase and the second argument is the name of the csv file to save. The csv file is tab-delimited, for PostgreSQL import use DELIMITER `E'\t'`.
