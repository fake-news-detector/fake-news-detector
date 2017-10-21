from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier


class ExtremelyBiased(BaseClassifier):
    name = "extremely_biased"

    def features_labels(self):
        df = self.load_links()

        df["is_extremely_biased"] = [
            category_id == categories["extremely_biased"]
            for category_id in df["category_id"]
        ]

        X = df["title"]
        y = df["is_extremely_biased"]

        return X, y
