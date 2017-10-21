import unittest

from robinho.model import Robinho

robinho = Robinho()
robinho.train()


def top_prediction(predictions):
    return max(predictions, key=lambda p: p['chance'])


class ModelTestCase(unittest.TestCase):
    def test_make_fake_news_predictions(self):
        predictions = Robinho().predict(
            "Novela apresentará Beijo gay infantil")
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 2)
        self.assertGreater(prediction['chance'], 0.5)

    def test_make_click_bait_predictions(self):
        predictions = Robinho().predict(
            "8 truques que os pintores de paredes não contam para você")
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 3)
        self.assertGreater(prediction['chance'], 0.5)

    def test_make_extremely_biased_predictions(self):
        predictions = Robinho().predict("Chora bandidagem")
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 4)
        self.assertGreater(prediction['chance'], 0.5)
