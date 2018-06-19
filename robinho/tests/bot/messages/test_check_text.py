import unittest
import robinho.model
from robinho.bot.messages.check_text import respond, is_valid_for_checking
from unittest.mock import patch

sample_hoax = """
Man Sues McDonalds For Still Being Depressed After Eating Happy Meal
“I bought my happy meal, thinking that that would be the perfect solution for my depression”
"""


class CheckTextTestCase(unittest.TestCase):
    @patch.object(robinho.model.Robinho, 'predict')
    def test_nothing_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 0.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        self.assertIn("anything wrong", respond(sample_hoax))
        mock_predict.assert_called_with("", sample_hoax, "")

    @patch.object(robinho.model.Robinho, 'predict')
    def test_one_thing_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 1.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        self.assertIn("I'm almost certain this is Fake News",
                      respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_two_things_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 1.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.6
                                     }
        self.assertIn(
            "I'm almost certain this is Fake News and this seems to be Clickbait",
            respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_multiple_things_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 1.0,
                                     'extremely_biased': 0.8,
                                     'clickbait': 0.6
                                     }
        self.assertIn(
            "I'm almost certain this is Fake News, this looks a lot like Extremely Biased content and this seems to be Clickbait",
            respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_only_reports_greater_than_half_predictions(self, mock_predict):
        mock_predict.return_value = {'fake_news': 0.4,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        self.assertNotIn("Fake News", respond(sample_hoax))

    def test_validate_prevent_small_texts(self):
        self.assertEqual(False, is_valid_for_checking("foo bar baz qux"))

    def test_validate_allow_texts(self):
        self.assertEqual(True, is_valid_for_checking(sample_hoax))

    def test_validate_allow_urls(self):
        self.assertEqual(True, is_valid_for_checking("http://www.google.com"))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_detects_language_from_content_and_returns_translated_response(self, mock_predict):
        sample_hoax_pt = """
        Copiei do Facebook: “Há dois dias que faço buscas e pesquisas em todos os tribunais do sul,
        sudeste e centro-oeste, buscando ações em que Gilmar Mendes houvesse atuado como advogado…
        """
        mock_predict.return_value = {'fake_news': 0.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        self.assertIn("nada de errado", respond(sample_hoax_pt))

    @patch.object(robinho.model.Robinho, 'find_keywords')
    def test_adds_google_search(self, mock_find_keywords):
        mock_find_keywords.return_value = ['foo', 'bar', 'baz qux']
        self.assertIn("https://www.google.com/search?q=foo+bar+baz+qux",
                      respond(sample_hoax))
