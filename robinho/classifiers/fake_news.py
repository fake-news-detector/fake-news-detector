from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier
from sklearn.preprocessing import FunctionTransformer


class FakeNews(BaseClassifier):
    name = "fake_news"

    def features_labels(self):
        df = self.load_links()

        df["is_fake_news"] = [
            category_id == categories["fake_news"]
            for category_id in df["category_id"]
        ]

        X = df[["title"]]
        y = df["is_fake_news"]

        return X, y

    def classifier(self):
        return Pipeline([
            ('selector', FunctionTransformer(self.extract_title, validate=False)),
            ('vect', CountVectorizer(ngram_range=(2, 2))),
            ('tfidf', TfidfTransformer()),
            ('sampling', RandomUnderSampler()),
            ('clf', MultinomialNB()),
        ])
