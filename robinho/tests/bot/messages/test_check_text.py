import unittest
import robinho.model
from robinho.bot.messages.check_text import respond
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
        self.assertIn(
            "I could not understand what you mean, if you want to check weather something is Fake News, please, paste a link or a text here",
            respond("foo bar baz qux"))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_validate_allow_texts_and_predict_with_it(self, mock_predict):
        mock_predict.return_value = {'fake_news': 0.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        respond(sample_hoax)

        mock_predict.assert_called_with("", sample_hoax, "")
