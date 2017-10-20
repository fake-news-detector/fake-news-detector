import pandas as pd
import pickle


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


def save(clf, model_name):
    print("Saving model...")
    with open('data/' + model_name + '.pkl', "wb") as f:
        pickle.dump(clf, f)


def load(model_name):
    print("Loading model...")
    with open('data/' + model_name + '.pkl', "rb") as f:
        return pickle.load(f)


def predict(model_name, title):
    return load(model_name).predict_proba([title])[0][1]
