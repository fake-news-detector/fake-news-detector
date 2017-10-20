import pandas as pd


def load_links():
    try:
        print("Loading local links data...")
        df = pd.read_csv("data/links.csv")
    except:
        print("Downloading links data...")
        df = pd.read_json(
            "http://fake-news-detector-api.herokuapp.com/links/all")
        df.to_csv("data/links.csv")

    df.dropna(subset=["title"], inplace=True)

    return df
