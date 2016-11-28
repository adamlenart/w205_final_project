from goodreads import client
gc = client.GoodreadsClient(<api key>,<secret key>)

book = gc.book(1)

print book.title ,book.isbn, book.average_rating
