from robinho.classifiers.fake_news import FakeNews
from robinho.classifiers.click_bait import ClickBait
from robinho.classifiers.extremely_biased import ExtremelyBiased
from robinho.categories import categories


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

    def predict(self, title, content):
        predictions = []
        for category, classifier in self.classifiers.items():
            score = classifier.predict(title, content)
            if score > 0.5:
                predictions.append({
                    'category_id': categories[category],
                    'chance': score
                })

        return predictions
