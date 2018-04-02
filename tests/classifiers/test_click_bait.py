import unittest

from robinho.classifiers.click_bait import ClickBait
from tests.helpers import test_scores_snapshot
import pandas as pd

model = ClickBait()
X, y = model.features_labels()


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
            self, "ClickBait", model)

        self.assertGreater(accuracy, 0.64)
        self.assertGreater(f1, 0.63)
        self.assertGreater(positive_recall, 0.67)

    def test_make_predictions(self):
        model.train()
        self.assertGreater(model.predict(
            "8 truques que os pintores de paredes não contam para você", ""), 0.55)
