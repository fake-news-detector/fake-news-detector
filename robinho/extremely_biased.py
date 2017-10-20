from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
import pickle
from robinho.data import load_links


def classifier():
    return Pipeline([
        ('vect', CountVectorizer(ngram_range=(1, 1))),
        ('tfidf', TfidfTransformer()),
        ('sampling', RandomUnderSampler()),
        ('clf', MultinomialNB()),
    ])


def features_labels():
    df = load_links()

    df["is_biased"] = [category_id == 4 for category_id in df["category_id"]]

    X = df["title"]
    y = df["is_biased"]

    return X, y


def train():
    X, y = features_labels()

    print("Fitting data...")
    clf = classifier()
    clf = clf.fit(X, y)

    print("Saving model...")
    with open('data/extremely_biased.pkl', "wb") as f:
        pickle.dump(clf, f)


def load():
    print("Loading model...")
    with open('data/extremely_biased.pkl', "rb") as f:
        return pickle.load(f)


def predict(title):
    return load().predict_proba([title])[0][1]
