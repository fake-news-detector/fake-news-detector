import pandas as pd
import pickle

categories = {"fake_news": 2, "click_bait": 3, "extremely_biased": 4}


def load_links():
    try:
        df = pd.read_csv("data/links.csv")
    except:
        print("Downloading links data...")
        df = pd.read_json(
            "http://fake-news-detector-api.herokuapp.com/links/all")
        df.to_csv("data/links.csv")

    df.dropna(subset=["title"], inplace=True)

    return df


def save(clf, model_name):
    with open('data/' + model_name + '.pkl', "wb") as f:
        pickle.dump(clf, f)


def load(model_name):
    with open('data/' + model_name + '.pkl', "rb") as f:
        return pickle.load(f)


def predict(model, title):
    return model.predict_proba([title])[0][1]
