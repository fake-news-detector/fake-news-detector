import unittest

from robinho.classifiers.click_bait import ClickBait
from tests.helpers import test_scores_snapshot
import pandas as pd

model = ClickBait()


class ClickBaitTestCase(unittest.TestCase):
    def test_filter_small_title(self):
        df = pd.DataFrame()
        df['title'] = ["Example"]

        self.assertEqual(model.filter(df).bool(), False)

    def test_filter_bigger_title(self):
        df = pd.DataFrame()
        df['title'] = ["8 truques que os pintores de paredes não contam para você"]

        self.assertEqual(model.filter(df).bool(), True)

    def test_scores_snapshot(self):
        accuracy, f1, positive_recall = test_scores_snapshot(
            self, "ClickBait", model, 1)

        self.assertGreater(accuracy, 0.96)
        self.assertGreater(f1, 0.96)
        self.assertGreater(positive_recall, 0.97)

    def test_make_predictions(self):
        model.train()
        self.assertGreater(model.predict(
            "8 truques que os pintores de paredes não contam para você", "", "http://example.com"), 0.9)
