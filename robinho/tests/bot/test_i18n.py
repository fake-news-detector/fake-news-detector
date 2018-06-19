import unittest
from robinho.bot.i18n import translate, detect


class I18nTestCase(unittest.TestCase):
    def test_translate_english(self):
        self.assertIn('anything wrong', translate('en', 'NOTHING_WRONG'))

    def test_translate_portuguese(self):
        self.assertIn('nada de errado', translate('pt', 'NOTHING_WRONG'))

    def test_translate_spanish(self):
        self.assertIn('nada de malo', translate('es', 'NOTHING_WRONG'))

    def test_translate_unknown_languages_fallbacks_to_english(self):
        self.assertIn('anything wrong', translate('de', 'NOTHING_WRONG'))

    def test_detects_language(self):
        self.assertEqual('es', detect('Una prueba más'))

    def test_detects_language_as_english_when_cannot_tell(self):
        self.assertEqual('en', detect('11111'))
