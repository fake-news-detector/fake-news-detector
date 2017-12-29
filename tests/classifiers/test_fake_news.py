import unittest

from robinho.classifiers.fake_news import FakeNews
from tests.helpers import test_multiple

model = FakeNews()
X, y = model.features_labels()


class FakeNewsTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        avg_accuracy, avg_f1, avg_positive_recall = test_multiple(
            X, y, model.classifier())

        self.avg_accuracy = avg_accuracy
        self.avg_f1 = avg_f1
        self.avg_positive_recall = avg_positive_recall

    def test_accuracy(self):
        self.assertGreater(self.avg_accuracy, 0.81)

    def test_f1(self):
        self.assertGreater(self.avg_f1, 0.58)

    def test_positive_recall(self):
        self.assertGreater(self.avg_positive_recall, 0.45)

    def test_make_predictions(self):
        model.train()
        title = "Novela apresentará Beijo gay infantil"
        content = "O programa Encontro, abordou nesta manhã, mais uma vez a questão das crianças transgênero. “crianças que não se identificam com o sexo com que nasceram”. Especialista convidado foi o psiquiatra Alex Sedha, que é coordenador do Ambulatório transdisciplinar de identidade de gênero e orientação sexual. Ele fez questão de frisar que “Não tem nada de errado” com as crianças que desde cedo acreditam ter nascido “no corpo errado”. Citou ainda que atende meninos e meninas com “3 ou 4 anos de idade”."

        self.assertGreater(
            FakeNews().predict(title, content), 0.53)
