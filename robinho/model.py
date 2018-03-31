from robinho.classifiers.fake_news import FakeNews
from robinho.classifiers.click_bait import ClickBait
from robinho.classifiers.extremely_biased import ExtremelyBiased
from robinho.classifiers.keywords import Keywords

keywords = Keywords()


class Robinho():
    def __init__(self):
        self.classifiers = {
            "fake_news": FakeNews(),
            "extremely_biased": ExtremelyBiased(),
            "clickbait_title": ClickBait(),
        }

    def train(self):
        for _, classifier in self.classifiers.items():
            classifier.train()
        keywords.train()

    def predict(self, title, content):
        def predict_class(name):
            return self.classifiers[name].predict(title, content)

        return {
            "fake_news": predict_class("fake_news"),
            "extremely_biased": predict_class("extremely_biased"),
            "clickbait_title": predict_class("clickbait_title")
        }

    def find_keywords(self, title, content):
        return keywords.find_keywords(title, content)
