import unittest

from robinho.classifiers.click_bait import ClickBait
from tests.helpers import test_scores_snapshot

model = ClickBait()
X, y = model.features_labels()


class ClickBaitTestCase(unittest.TestCase):
    def test_scores_snapshot(self):
        accuracy, f1, positive_recall = test_scores_snapshot(
            self, "ClickBait", model)

        self.assertGreater(accuracy, 0.76)
        self.assertGreater(f1, 0.76)
        self.assertGreater(positive_recall, 0.71)

    def test_make_predictions(self):
        model.train()
        self.assertGreater(ClickBait().predict(
            "8 truques que os pintores de paredes não contam para você", ""), 0.58)
