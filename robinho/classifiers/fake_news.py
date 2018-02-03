from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier
from sklearn.preprocessing import FunctionTransformer
from robinho.marisa_vectorizers import MarisaTfidfVectorizer


class FakeNews(BaseClassifier):
    name = "fake_news"

    def features_labels(self):
        df = self.load_links()

        df["is_fake_news"] = [
            category_id == categories["fake_news"]
            for category_id in df["category_id"]
        ]

        X = df[["title", "content"]]
        y = df["is_fake_news"]

        return self.undersample_data(X, y)

    def preprocess(self, X):
        texts = X['title'] + ' ' + X['content']

        return texts

    def classifier(self):
        return Pipeline([
            ('preprocess', FunctionTransformer(
                self.preprocess, validate=False)),
            ('tfidf', MarisaTfidfVectorizer(
                strip_accents='ascii',
                ngram_range=(1, 3),
                max_df=0.5,
                min_df=5,
                use_idf=True)),
            ('sampling',
             RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED)),
            ('clf', MultinomialNB(fit_prior=False)),
        ])
