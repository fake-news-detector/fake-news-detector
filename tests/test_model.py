import unittest

from robinho.model import Robinho

robinho = Robinho()


class ModelTestCase(unittest.TestCase):
    def test_make_fake_news_predictions(self):
        predictions = robinho.predict(
            "Novela apresentará Beijo gay infantil", "O programa Encontro, abordou nesta manhã, mais uma vez a questão das crianças transgênero. “crianças que não se identificam com o sexo com que nasceram”. Especialista convidado foi o psiquiatra Alex Sedha, que é coordenador do Ambulatório transdisciplinar de identidade de gênero e orientação sexual. Ele fez questão de frisar que “Não tem nada de errado” com as crianças que desde cedo acreditam ter nascido “no corpo errado”. Citou ainda que atende meninos e meninas com “3 ou 4 anos de idade”.", "http://example.com")

        self.assertGreater(predictions['fake_news'], 0.5)

    def test_make_click_bait_predictions(self):
        predictions = robinho.predict(
            "20+ Art History Tweets That Prove Nothing Has Changed In 100s Of Years", "", "http://example.com")

        self.assertGreater(predictions['clickbait'], 0.5)

    def test_make_extremely_biased_predictions(self):
        title = "Em entrevista exclusiva, psicóloga afirma que existe um movimento para “naturalizar a pedofilia”"
        content = "Marisa Lobo, psicóloga e especialista em Direitos Humanos, concedeu uma entrevista exclusiva ao JornaLivre para tratar sobre a polêmica do caso “MAM” e a “performance La Bête”. Confira a entrevista: JL: Como mulher e mãe, quais foram suas impressões ao assistir pela primeira vez ao vídeo da performance que ocorreu na abertura do 35 Panorama da Arte Brasileira do MAM-SP?"
        url = "http://example.com"

        predictions = robinho.predict(title, content, url)

        self.assertGreater(predictions['extremely_biased'], 0.5)

    def test_find_keywords(self):
        title = "Em entrevista exclusiva, psicóloga afirma que existe um movimento para “naturalizar a pedofilia”"
        content = "Marisa Lobo, psicóloga e especialista em Direitos Humanos, concedeu uma entrevista exclusiva ao JornaLivre para tratar sobre a polêmica do caso “MAM” e a “performance La Bête”. Confira a entrevista: JL: Como mulher e mãe, quais foram suas impressões ao assistir pela primeira vez ao vídeo da performance que ocorreu na abertura do 35 Panorama da Arte Brasileira do MAM-SP?"

        keywords = robinho.find_keywords(title, content)

        self.assertIn("entrevista", keywords)
