from robinho.model import Robinho
import re
import requests
import json
import robinho.bot.messages.chitchat as chitchat

robinho = Robinho()


def certainty_level(chance):
    rebalancedChance = (chance * 100 - 50) * 2
    if rebalancedChance >= 66:
        return "I'm almost certain this is"
    elif rebalancedChance >= 33:
        return "this looks a lot like"
    else:
        return "this seems to be"


def is_valid_for_checking(message):
    words = message.split(" ")
    return (len(words) > 8 or is_link(message))


def is_link(message):
    return (re.match(r'^http', message) is not None)


def respond_text_prediction(predicted):
    response = ""
    categories = []
    if predicted['fake_news'] > 0.5:
        categories.append(certainty_level(
            predicted['fake_news']) + " Fake News")
    if predicted['extremely_biased'] > 0.5:
        categories.append(certainty_level(
            predicted['extremely_biased']) + " Extremely Biased content")
    if predicted['clickbait'] > 0.5:
        categories.append(certainty_level(
            predicted['clickbait']) + " Clickbait")

    if categories == []:
        response += "There doesn't seem to be anything wrong with this content"
    else:
        response += re.sub(r'(.*)\,', r"\1 and", ", ".join(categories))

    return response


def respond(message):
    if not is_valid_for_checking(message):
        return chitchat.respond(message)
    elif is_link(message):
        try:
            response = requests.get("https://api.fakenewsdetector.org/votes", params={
                'url': message,
                'title': ''
            }, timeout=10)
            predicted = json.loads(response.text)['robot']
        except Exception as err:
            print("Error", err)
            return "Sorry, an error ocurred, please try again"
    else:
        predicted = robinho.predict("", message, "")

    return respond_text_prediction(predicted)
