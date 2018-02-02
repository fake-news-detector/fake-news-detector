import unittest

from robinho.classifiers.extremely_biased import ExtremelyBiased
from tests.helpers import test_scores_snapshot

model = ExtremelyBiased()
X, y = model.features_labels()


class ExtremelyBiasedTestCase(unittest.TestCase):
    def test_scores_snapshot(self):
        accuracy, f1, positive_recall = test_scores_snapshot(
            self, "ExtremelyBiased", model)

        self.assertGreater(accuracy, 0.72)
        self.assertGreater(f1, 0.72)
        self.assertGreater(positive_recall, 0.77)

    def test_make_predictions(self):
        model.train()
        title = "Chora bandidagem"
        content = "Chora bandidagem. Chora turma dos direitos humanos. O bagulho agora vai ficar frenético, como diz a bandidagem. O presidente Michel Temer acaba de sancionar o projeto de lei aprovado pelo Congresso Nacional que livra os militares envolvidos em conflitos com civis de serem processados na Justiça comum. O projeto de lei que teve o aval de Temer transfere para a Justiça Militar os casos de crimes dolosos contra a vida de civis praticados por militares no exercício de missões como as realizadas nos morros cariocas."

        self.assertGreater(ExtremelyBiased().predict(title, content), 0.61)
