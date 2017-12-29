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
        self.assertGreater(self.avg_accuracy, 0.68)

    def test_f1(self):
        self.assertGreater(self.avg_f1, 0.58)

    def test_positive_recall(self):
        self.assertGreater(self.avg_positive_recall, 0.73)

    def test_make_predictions(self):
        model.train()
        title = "Chora bandidagem"
        content = "Chora bandidagem. Chora turma dos direitos humanos. O bagulho agora vai ficar frenético, como diz a bandidagem. O presidente Michel Temer acaba de sancionar o projeto de lei aprovado pelo Congresso Nacional que livra os militares envolvidos em conflitos com civis de serem processados na Justiça comum. O projeto de lei que teve o aval de Temer transfere para a Justiça Militar os casos de crimes dolosos contra a vida de civis praticados por militares no exercício de missões como as realizadas nos morros cariocas."

        self.assertGreater(ExtremelyBiased().predict(title, content), 0.61)
