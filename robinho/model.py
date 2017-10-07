import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
import pickle


def load_data():
    try:
        print("Loading local data...")
        df = pd.read_csv("data/links.csv")
    except:
        print("Downloading data...")
        df = pd.read_json(
            "http://fake-news-detector-api.herokuapp.com/links/all")
        df.to_csv("data/links.csv")

    X = df["title"]
    y = df["category_id"]

    return X, y


def classifier():
    return Pipeline([
        ('vect', CountVectorizer()),
        ('tfidf', TfidfTransformer()),
        ('sampling', RandomUnderSampler()),
        ('clf', MultinomialNB()),
    ])


def train():
    X, y = load_data()

    print("Fitting data...")
    clf = classifier()
    clf = clf.fit(X, y)

    print("Saving model...")
    pickle.dump(clf, open('model.pkl', 'wb'))


def predict(titles):
    print("Loading model...")
    clf = pickle.load(open('model.pkl', 'rb'))

    return clf.predict(titles)
