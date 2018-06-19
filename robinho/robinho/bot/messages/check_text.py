from robinho.model import Robinho
import re
import requests
import json
import robinho.bot.messages.chitchat as chitchat
import robinho.bot.i18n as i18n

robinho = Robinho()


def certainty_level(language, chance):
    rebalancedChance = (chance * 100 - 50) * 2
    if rebalancedChance >= 66:
        return i18n.translate(language, "ALMOST_CERTAIN")
    elif rebalancedChance >= 33:
        return i18n.translate(language, "LOOKS_A_LOT_LIKE")
    else:
        return i18n.translate(language, "SEEMS_TO_BE")


def is_valid_for_checking(message):
    words = message.split(" ")
    return (len(words) > 8 or is_link(message))


def is_link(message):
    return (re.match(r'^http', message) is not None)


def respond_text_prediction(language, predicted):
    response = ""
    categories = []
    if predicted['fake_news'] > 0.5:
        categories.append(certainty_level(language, predicted['fake_news']) +
                          " Fake News")
    if predicted['extremely_biased'] > 0.5:
        categories.append(certainty_level(language, predicted['extremely_biased']) +
                          " " + i18n.translate(language, "EXTREMELY_BIASED"))
    if predicted['clickbait'] > 0.5:
        categories.append(certainty_level(language, predicted['clickbait']) +
                          " Clickbait")

    if categories == []:
        response += i18n.translate(language, "NOTHING_WRONG")
    else:
        response += re.sub(r'(.*)\,', r"\1 and", ", ".join(categories))
        response = re.sub('^([a-z])', lambda x: x.groups()
                          [0].upper(), response)

    return response


def respond(message):
    if not is_valid_for_checking(message):
        return chitchat.respond(message)

    language = i18n.detect(message)
    if is_link(message):
        try:
            response = requests.get("https://api.fakenewsdetector.org/votes", params={
                'url': message,
                'title': ''
            }, timeout=10)
            predicted = json.loads(response.text)['robot']
        except Exception as err:
            print("Error", err)
            return i18n.translate(language, "SORRY_ERROR")
    else:
        predicted = robinho.predict("", message, "")

    return respond_text_prediction(language, predicted)
