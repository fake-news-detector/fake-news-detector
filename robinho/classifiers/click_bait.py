from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier
from sklearn.naive_bayes import MultinomialNB
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline
from sklearn.preprocessing import FunctionTransformer
from robinho.marisa_vectorizers import MarisaTfidfVectorizer


class ClickBait(BaseClassifier):
    name = "click_bait"

    def features_labels(self):
        df = self.load_links()

        df["is_click_bait"] = [
            category_id == categories["click_bait"]
            for category_id in df["category_id"]
        ]

        X = df[["title", "content"]]
        y = df["is_click_bait"]

        return self.undersample_data(X, y)

    def classifier(self):
        return Pipeline([
            ('selector', FunctionTransformer(self.extract_title, validate=False)),
            ('tfidf', MarisaTfidfVectorizer(strip_accents='ascii', ngram_range=(2, 1))),
            ('sampling', RandomUnderSampler(random_state=BaseClassifier.RANDOM_SEED)),
            ('clf', MultinomialNB()),
        ])
