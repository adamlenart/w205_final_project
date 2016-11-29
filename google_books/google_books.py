import googlebooks
api = googlebooks.Api()

result = api.list('q:beautiful mind')

for i in range(len(result["items"])):
    if result["items"][i]["volumeInfo"].get("industryIdentifiers") is not None and result["items"][i]["volumeInfo"].get("categories") is not None:
        print result["items"][i]["volumeInfo"]["title"] ,result["items"][i]["volumeInfo"]["industryIdentifiers"][0]["identifier"] ,\
              result["items"][i]["volumeInfo"]["categories"][0]

