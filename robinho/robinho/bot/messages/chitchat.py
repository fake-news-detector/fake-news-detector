from chatterbot import ChatBot
from chatterbot.trainers import ListTrainer

chatbot = ChatBot(
    'Robinho',
    logic_adapters=[
        {
            "import_path": "chatterbot.logic.BestMatch",
            "statement_comparison_function": "chatterbot.comparisons.levenshtein_distance",
            "response_selection_method": "chatterbot.response_selection.get_first_response"
        }
        # {
        #     'import_path': 'chatterbot.logic.LowConfidenceAdapter',
        #     'threshold': 0.65,
        #     'default_response': 'IDK'
        # }
    ],
    trainer='chatterbot.trainers.ChatterBotCorpusTrainer'
)


def train():
    chatbot.train("chatterbot.corpus.english")
    chatbot.train("chatterbot.corpus.spanish")
    chatbot.train("chatterbot.corpus.portuguese")

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
    chatbot.set_trainer(ListTrainer)
    for question in questions:
        chatbot.train([
            question,
            response
        ])


def respond(message):
    response = chatbot.get_response(message)
    if response.confidence < 0.65:
        return ("I could not understand what you mean, " +
                "if you want to check weather something is Fake News, " +
                "please, paste a link or a text here")

    return response.text
