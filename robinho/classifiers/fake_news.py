from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier
from sklearn.preprocessing import FunctionTransformer
from sklearn.pipeline import FeatureUnion


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

        return X, y

    def classifier(self):
        return Pipeline([
            ('features', FeatureUnion(
                transformer_list=[
                    ('title', Pipeline([
                        ('selector1', FunctionTransformer(self.extract_title, validate=False)),
                        ('vect1', CountVectorizer(ngram_range=(4, 4))),
                        ('tfidf1', TfidfTransformer())
                    ])),
                    ('content', Pipeline([
                        ('selector2', FunctionTransformer(self.extract_content, validate=False)),
                        ('vect2', CountVectorizer(ngram_range=(4, 4))),
                        ('tfidf2', TfidfTransformer())
                    ]))
                ],
                transformer_weights={
                    'title': 0.5,
                    'content': 1.0,
                },
            )),
            ('sampling', RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED)),
            ('clf', MultinomialNB())
        ])
