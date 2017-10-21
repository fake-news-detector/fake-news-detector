import robinho.fake_news as fake_news
import robinho.click_bait as click_bait
import robinho.extremely_biased as extremely_biased
import robinho.common as common


class Robinho():
    def train(self):
        fake_news.train()
        click_bait.train()
        extremely_biased.train()

    def load(self):
        self.fake_news = fake_news.load()
        self.click_bait = click_bait.load()
        self.extremely_biased = extremely_biased.load()

    def predict(self, title):
        classifiers = {
            "fake_news": self.fake_news,
            "click_bait": self.click_bait,
            "extremely_biased": self.extremely_biased
        }

        predictions = []
        for category in ["fake_news", "click_bait", "extremely_biased"]:
            score = common.predict(classifiers[category], title)
            if score > 0.5:
                predictions.append({
                    'category_id': common.categories[category],
                    'chance': score
                })

        return predictions
