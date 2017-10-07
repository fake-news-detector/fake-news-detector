import pandas as pd

try:
    df = pd.read_csv("links.csv")
except:
    df = pd.read_json("http://fake-news-detector-api.herokuapp.com/links/all")
    df.to_csv("links.csv")

print(df)
