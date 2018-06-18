from robinho.model import Robinho
import re
import requests
import json

robinho = Robinho()


def certainty_level(chance):
    rebalancedChance = (chance * 100 - 50) * 2
    if rebalancedChance >= 66:
        return "I'm almost certain this is"
    elif rebalancedChance >= 33:
        return "this looks a lot like"
    else:
        return "this seems to be"


def respond_validation(text):
    words = text.split(" ")
    if len(words) < 8:
        return ("I could not understand what you mean, " +
                "if you want to check weather something is Fake News, " +
                "please, paste a link or a text here")

    return ""


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
        response += "Based on what I've seen before, "
        response += re.sub(r'(.*)\,', r"\1 and", ", ".join(categories))

    return response


def respond(message):
    is_link = re.match(r'^http', message)

    validation = respond_validation(message)
    if not is_link and validation != "":
        return validation

    if is_link:
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
