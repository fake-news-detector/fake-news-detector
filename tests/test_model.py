import unittest

from robinho.model import Robinho

robinho = Robinho()


class ModelTestCase(unittest.TestCase):
    def test_make_fake_news_predictions(self):
        predictions = robinho.predict(
            "Novela apresentará Beijo gay infantil", "")

        self.assertGreater(predictions['fake_news'], 0.5)

    def test_make_click_bait_predictions(self):
        predictions = robinho.predict(
            "20+ Art History Tweets That Prove Nothing Has Changed In 100s Of Years", "")

        self.assertGreater(predictions['clickbait'], 0.5)

    def test_make_extremely_biased_predictions(self):
        title = "Em entrevista exclusiva, psicóloga afirma que existe um movimento para “naturalizar a pedofilia”"
        content = "Marisa Lobo, psicóloga e especialista em Direitos Humanos, concedeu uma entrevista exclusiva ao JornaLivre para tratar sobre a polêmica do caso “MAM” e a “performance La Bête”. Confira a entrevista: JL: Como mulher e mãe, quais foram suas impressões ao assistir pela primeira vez ao vídeo da performance que ocorreu na abertura do 35 Panorama da Arte Brasileira do MAM-SP?"

        predictions = robinho.predict(title, content)

        self.assertGreater(predictions['extremely_biased'], 0.5)

    def test_find_keywords(self):
        title = "Em entrevista exclusiva, psicóloga afirma que existe um movimento para “naturalizar a pedofilia”"
        content = "Marisa Lobo, psicóloga e especialista em Direitos Humanos, concedeu uma entrevista exclusiva ao JornaLivre para tratar sobre a polêmica do caso “MAM” e a “performance La Bête”. Confira a entrevista: JL: Como mulher e mãe, quais foram suas impressões ao assistir pela primeira vez ao vídeo da performance que ocorreu na abertura do 35 Panorama da Arte Brasileira do MAM-SP?"

        keywords = robinho.find_keywords(title, content)

        self.assertIn("entrevista", keywords)
