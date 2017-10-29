import unittest

from robinho.model import Robinho

robinho = Robinho()
robinho.train()


def top_prediction(predictions):
    return max(predictions, key=lambda p: p['chance'])


class ModelTestCase(unittest.TestCase):
    def test_make_fake_news_predictions(self):
        predictions = Robinho().predict(
            "Novela apresentará Beijo gay infantil", "")
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 2)
        self.assertGreater(prediction['chance'], 0.5)

    def test_make_click_bait_predictions(self):
        predictions = Robinho().predict(
            "8 truques que os pintores de paredes não contam para você", "")
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 3)
        self.assertGreater(prediction['chance'], 0.5)

    def test_make_extremely_biased_predictions(self):
        title = "Chora bandidagem"
        content = "Chora bandidagem. Chora turma dos direitos humanos. O bagulho agora vai ficar frenético, como diz a bandidagem. O presidente Michel Temer acaba de sancionar o projeto de lei aprovado pelo Congresso Nacional que livra os militares envolvidos em conflitos com civis de serem processados na Justiça comum. O projeto de lei que teve o aval de Temer transfere para a Justiça Militar os casos de crimes dolosos contra a vida de civis praticados por militares no exercício de missões como as realizadas nos morros cariocas."

        predictions = Robinho().predict(title, content)
        prediction = top_prediction(predictions)

        self.assertEqual(prediction['category_id'], 4)
        self.assertGreater(prediction['chance'], 0.5)
