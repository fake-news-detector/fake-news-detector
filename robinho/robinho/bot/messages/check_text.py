from robinho.model import Robinho
import re

robinho = Robinho()


def certainty_level(chance):
    rebalancedChance = (chance * 100 - 50) * 2
    if rebalancedChance >= 66:
        return "I'm almost certain it is"
    elif rebalancedChance >= 33:
        return "it looks a lot like"
    else:
        return "it looks like"


def respond(text):
    predicted = robinho.predict("", text, "")

    text = ""
    categories = []
    if predicted['fake_news'] > 0.5:
        categories.append(certainty_level(
            predicted['fake_news']) + " Fake News")
    if predicted['extremely_biased'] > 0.5:
        categories.append(certainty_level(
            predicted['extremely_biased']) + " Extremely Biased")
    if predicted['clickbait'] > 0.5:
        categories.append(certainty_level(
            predicted['clickbait']) + " Clickbait")

    text += "I've compared this with other texts I've seen, and "
    text += re.sub(r'(.*)\,', r"\1 and", ", ".join(categories))

    if categories == []:
        text += "there doesn't seem to be anything wrong with this content"

    return text
