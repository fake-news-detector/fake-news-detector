import unittest

from robinho.classifiers.extremely_biased import ExtremelyBiased
from tests.helpers import test_multiple

model = ExtremelyBiased()
X, y = model.features_labels()


class ExtremelyBiasedTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        avg_accuracy, avg_f1, avg_positive_recall = test_multiple(
            X, y, model.classifier())

        self.avg_accuracy = avg_accuracy
        self.avg_f1 = avg_f1
        self.avg_positive_recall = avg_positive_recall

    def test_accuracy(self):
        self.assertGreater(self.avg_accuracy, 0.5)

    def test_f1(self):
        self.assertGreater(self.avg_f1, 0.5)

    def test_positive_recall(self):
        self.assertGreater(self.avg_positive_recall, 0.8)

    def test_make_predictions(self):
        model.train()
        self.assertGreater(ExtremelyBiased().predict("Chora bandidagem"), 0.5)
