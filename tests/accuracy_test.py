import unittest

import robinho.model as robinho
from sklearn.model_selection import train_test_split


class AccuracyTestCase(unittest.TestCase):
    def test_accuracy(self):
        X, y = robinho.load_data()

        X_train, X_test, y_train, y_test = train_test_split(X, y)

        clf = robinho.classifier()
        clf = clf.fit(X_train, y_train)

        accuracy = clf.score(X_test, y_test)

        self.assertGreater(accuracy, 0.1)
