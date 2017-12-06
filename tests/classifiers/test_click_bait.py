import unittest

from robinho.classifiers.click_bait import ClickBait
from tests.helpers import test_multiple

model = ClickBait()
X, y = model.features_labels()


class ClickBaitTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        avg_accuracy, avg_f1, avg_positive_recall = test_multiple(
            X, y, model.classifier())

        self.avg_accuracy = avg_accuracy
        self.avg_f1 = avg_f1
        self.avg_positive_recall = avg_positive_recall

    def test_accuracy(self):
        self.assertGreater(self.avg_accuracy, 0.67)

    def test_f1(self):
        self.assertGreater(self.avg_f1, 0.5)

    def test_positive_recall(self):
        self.assertGreater(self.avg_positive_recall, 0.40)

    def test_make_predictions(self):
        model.train()
        self.assertGreater(ClickBait().predict(
            "8 truques que os pintores de paredes não contam para você", ""), 0.5)
