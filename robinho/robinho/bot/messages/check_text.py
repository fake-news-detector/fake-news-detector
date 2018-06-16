import robinho.categories as categories
from robinho.model import Robinho

robinho = Robinho()


def respond(text):
    predicted = robinho.predict("", text, "")
    return str(predicted)
