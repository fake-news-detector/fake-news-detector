import unittest

from robinho.classifiers.fake_news import FakeNews
from tests.helpers import test_scores_snapshot

model = FakeNews()


class FakeNewsTestCase(unittest.TestCase):
    def test_scores_snapshot(self):
        accuracy, f1, positive_recall = test_scores_snapshot(
            self, "FakeNews", model)

        self.assertGreater(accuracy, 0.6)
        self.assertGreater(f1, 0.6)
        self.assertGreater(positive_recall, 0.5)

    def test_make_predictions(self):
        title = "Novela apresentará Beijo gay infantil"
        content = "O programa Encontro, abordou nesta manhã, mais uma vez a questão das crianças transgênero. “crianças que não se identificam com o sexo com que nasceram”. Especialista convidado foi o psiquiatra Alex Sedha, que é coordenador do Ambulatório transdisciplinar de identidade de gênero e orientação sexual. Ele fez questão de frisar que “Não tem nada de errado” com as crianças que desde cedo acreditam ter nascido “no corpo errado”. Citou ainda que atende meninos e meninas com “3 ou 4 anos de idade”."
        url = "http://example.com"

        model.train()
        self.assertGreater(
            model.predict(title, content, url), 0.71)
