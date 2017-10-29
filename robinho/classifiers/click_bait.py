from robinho.categories import categories
from robinho.classifiers.base import BaseClassifier


class ClickBait(BaseClassifier):
    name = "click_bait"

    def features_labels(self):
        df = self.load_links()

        df["is_click_bait"] = [
            category_id == categories["click_bait"]
            for category_id in df["category_id"]
        ]

        X = df[["title"]]
        y = df["is_click_bait"]

        return X, y
