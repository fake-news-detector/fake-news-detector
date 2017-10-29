import pandas as pd
import pickle
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer


class BaseClassifier():
    def __init__(self):
        try:
            with open('data/' + self.name + '.pkl', "rb") as f:
                self.clf = pickle.load(f)
        except:
            self.train()

    def features_labels(self):
        raise NotImplementedError

    def extract_title(self, X):
        return X['title']

    def extract_content(self, X):
        return X['content']

    def classifier(self):
        return Pipeline([
            ('selector', FunctionTransformer(self.extract_title, validate=False)),
            ('vect', CountVectorizer(ngram_range=(1, 1))),
            ('tfidf', TfidfTransformer()),
            ('sampling', RandomUnderSampler()),
            ('clf', MultinomialNB()),
        ])

    def load_links(self):
        try:
            df = pd.read_csv("data/links.csv")
        except:
            print("Downloading links data...")
            df = pd.read_json(
                "http://fake-news-detector-api.herokuapp.com/links/all")
            df.to_csv("data/links.csv")

        df.dropna(subset=["title"], inplace=True)
        df.dropna(subset=["content"], inplace=True)

        return df

    def train(self):
        X, y = self.features_labels()

        clf = self.classifier()
        clf = clf.fit(X, y)

        with open('data/' + self.name + '.pkl', "wb") as f:
            pickle.dump(clf, f)

        self.clf = clf

    def predict(self, title, content):
        df = pd.DataFrame()
        df['title'] = [title]
        df['content'] = [content]
        return self.clf.predict_proba(df)[0][1]
