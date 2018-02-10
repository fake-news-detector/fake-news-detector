from robinho.classifiers.fake_news import FakeNews
from robinho.classifiers.click_bait import ClickBait
from robinho.classifiers.extremely_biased import ExtremelyBiased
from robinho.categories import categories
from robinho.classifiers.keywords import Keywords

keywords = Keywords()


class Robinho():
    def __init__(self):
        self.classifiers = {
            "fake_news": FakeNews(),
            "click_bait": ClickBait(),
            "extremely_biased": ExtremelyBiased()
        }

    def train(self):
        for category, classifier in self.classifiers.items():
            classifier.train()
        keywords.train()

    def predict(self, title, content):
        predictions = []
        for category, classifier in self.classifiers.items():
            score = classifier.predict(title, content)

            # TODO: Remove this workaound
            if category == "fake_news":
                score = score - 0.1

            if score > 0.51:
                predictions.append({
                    'category_id': categories[category],
                    'chance': score
                })

        return predictions

    def find_keywords(self, title, content):
        return keywords.find_keywords(title, content)
