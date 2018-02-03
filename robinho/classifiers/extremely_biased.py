from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfTransformer
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from sklearn.pipeline import FeatureUnion
from sklearn.preprocessing import FunctionTransformer
from robinho.marisa_vectorizers import MarisaTfidfVectorizer


class ExtremelyBiased(BaseClassifier):
    name = "extremely_biased"

    def features_labels(self):
        df = self.load_links()

        df["is_extremely_biased"] = [
            category_id == categories["extremely_biased"]
            for category_id in df["category_id"]
        ]

        X = df[["title", "content"]]
        y = df["is_extremely_biased"]

        return self.undersample_data(X, y)

    def classifier(self):
        title_transformer = Pipeline([
            ('selector1', FunctionTransformer(self.extract_title, validate=False)),
            ('tfidf1', MarisaTfidfVectorizer(
                strip_accents='ascii', ngram_range=(2, 2)))
        ])

        content_transformer = Pipeline([
            ('selector2', FunctionTransformer(self.extract_content, validate=False)),
            ('tfidf2', MarisaTfidfVectorizer(
                strip_accents='ascii', ngram_range=(2, 2)))
        ])

        return Pipeline([
            ('features', FeatureUnion(
                transformer_list=[
                    ('title', title_transformer),
                    ('content', content_transformer)
                ],
                transformer_weights={
                    'title': 0.5,
                    'content': 1.0,
                },
            )),
            ('sampling', RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED)),
            ('clf', MultinomialNB())
        ])
