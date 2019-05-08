import robinho.bot.i18n as i18n
from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer, ListTrainer

chatbot = ChatBot(
    'Robinho',
    logic_adapters=["chatterbot.logic.BestMatch"],
    trainer='chatterbot.trainers.ChatterBotCorpusTrainer'
)

corpus_trainer = ChatterBotCorpusTrainer(chatbot)
list_trainer = ListTrainer(chatbot)


def train():
    corpus_trainer.train("chatterbot.corpus.english")
    corpus_trainer.train("chatterbot.corpus.spanish")
    corpus_trainer.train("chatterbot.corpus.portuguese")

    # en
    questions = ["help", "what do you do", "how does this work",
                 "how do I use this", "what can you do for me"]
    response = ("I try to detect hoaxes and fake news, " +
                "you can paste a text or a link here to check")
    train_multiple_questions(questions, response)

    # pt
    questions = ["ajuda", "o que você faz", "como isso funciona",
                 "como usa isso", "o que você pode fazer"]
    response = ("Eu tento detectar boatos e fake news, " +
                "você pode colar um texto ou link aqui para eu checar")
    train_multiple_questions(questions, response)

    # es
    questions = ["ayuda", "qué haces", "cómo funciona eso", "cómo funciona",
                 "cómo uso eso", "qué tu puedes hacer por mi"]
    response = ("Yo intento detectar rumores y fake news, " +
                "pega un texto o enlace acá para que yo haga la verificación")
    train_multiple_questions(questions, response)


def train_multiple_questions(questions, response):
    for question in questions:
        list_trainer.train([
            question,
            response
        ])


def respond(message):
    response = chatbot.get_response(message)
    if response.confidence < 0.60:
        language = i18n.detect(message)
        return i18n.translate(language, "COULD_NOT_UNDERSTAND")

    return response.text
