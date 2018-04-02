import unittest

from robinho.classifiers.base import BaseClassifier
import pandas as pd


class BaseClassifierTestCase(unittest.TestCase):
    def test_filter_small_text(self):
        df = pd.DataFrame()
        df['title'] = ["Example"]
        df['content'] = ["Foo Bar"]

        self.assertEqual(BaseClassifier.filter(None, df).bool(), False)

    def test_filter_bigger_text(self):
        df = pd.DataFrame()
        df['title'] = ["Example"]
        df['content'] = ["O programa Encontro, abordou nesta manhã, mais uma vez a questão das crianças transgênero. “crianças que não se identificam com o sexo com que nasceram”. Especialista convidado foi o psiquiatra Alex Sedha, que é coordenador do Ambulatório transdisciplinar de identidade de gênero e orientação sexual. Ele fez questão de frisar que “Não tem nada de errado” com as crianças que desde cedo acreditam ter nascido “no corpo errado”. Citou ainda que atende meninos e meninas com “3 ou 4 anos de idade”."]

        self.assertEqual(BaseClassifier.filter(None, df).bool(), True)

    def test_return_zero_if_filtered(self):
        title = "Example"
        content = "foo bar"

        class Sample():
            def filter(self, df):
                return BaseClassifier.filter(None, df)

        self.assertEqual(BaseClassifier.predict(Sample(), title, content), 0.0)
