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
        self.assertIn("I'm almost certain it is Fake News",
                      respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_two_things_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 1.0,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.6
                                     }
        self.assertIn(
            "I'm almost certain it is Fake News and it looks like Clickbait",
            respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_multiple_things_wrong(self, mock_predict):
        mock_predict.return_value = {'fake_news': 1.0,
                                     'extremely_biased': 0.8,
                                     'clickbait': 0.6
                                     }
        self.assertIn(
            "I'm almost certain it is Fake News, it looks a lot like Extremely Biased and it looks like Clickbait",
            respond(sample_hoax))

    @patch.object(robinho.model.Robinho, 'predict')
    def test_only_reports_greater_than_half_predictions(self, mock_predict):
        mock_predict.return_value = {'fake_news': 0.4,
                                     'extremely_biased': 0.0,
                                     'clickbait': 0.0
                                     }
        self.assertNotIn("Fake News", respond(sample_hoax))
