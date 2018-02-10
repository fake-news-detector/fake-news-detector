import unittest

from robinho.classifiers.keywords import Keywords

model = Keywords()


class KeywordsTestCase(unittest.TestCase):
    def test_find_keywords_portuguese_text(self):
        title = "Novela apresentará Beijo gay infantil"
        content = "O programa Encontro, abordou nesta manhã, mais uma vez a questão das crianças transgênero. “crianças que não se identificam com o sexo com que nasceram”. Especialista convidado foi o psiquiatra Alex Sedha, que é coordenador do Ambulatório transdisciplinar de identidade de gênero e orientação sexual. Ele fez questão de frisar que “Não tem nada de errado” com as crianças que desde cedo acreditam ter nascido “no corpo errado”. Citou ainda que atende meninos e meninas com “3 ou 4 anos de idade”."

        keywords = model.find_keywords(title, content)

        self.assertIn('criancas', keywords)
        self.assertIn('beijo', keywords)
        self.assertIn('gay', keywords)

    def test_find_keywords_english_text(self):
        title = "Breaking: Top Leftists Call For Civil War"
        content = "The global elite are preparing for a major operation. The elite want to start a fight with Trump and American patriots to combat the current anti-globalist surge spreading throughout the world."

        keywords = model.find_keywords(title, content)

        self.assertIn('elite', keywords)
        self.assertIn('fight', keywords)

    def test_find_keywords_spanish_text(self):
        title = "Minuto a minuto de los Juegos Olímpicos de Invierno"
        content = """
        La llama olímpica arde en Pyoengchang. La ceremonia de apertura de los juegos de invierno 2018 fue deslumbrante pese a las bajas temperaturas. Fue una apertura espectacular y una ceremonia con alusiones a la paz y la armonía.

        Mientras los atletas desfilaban, soñando con hacer historia, las gradas fueron escenario de momentos significativos más relacionados con la política y la diplomacia que con el deporte.

        El deporte ha conseguido lo que a la diplomacia no le ha resultado fácil lograr: unir a dos países técnicamente en guerra desde más de seis décadas: Corea del Norte y del Sur.

        Aunque los deportistas están acostumbrados a competir en bajas temperaturas, los juegos de Pyeongchang van a ser muy fríos, tanto que el frío puede llegar a ser histórico, según los expertos.
        """

        keywords = model.find_keywords(title, content)

        self.assertIn('minuto', keywords)
        self.assertIn('historico', keywords)

    def test_returns_empty_for_small_texts(self):
        keywords = model.find_keywords("hello there", "")

        self.assertEqual(keywords, [])
