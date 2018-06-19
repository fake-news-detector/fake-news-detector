import langdetect

words_en = {
    'NOTHING_WRONG': "There doesn't seem to be anything wrong with this content",
    'SORRY_ERROR': "Sorry, an error ocurred, please try again",
    'ALMOST_CERTAIN': "I'm almost certain this is",
    'LOOKS_A_LOT_LIKE': "this looks a lot like",
    'SEEMS_TO_BE': "this seems to be",
    'EXTREMELY_BIASED': "Extremely Biased content",
    'COULD_NOT_UNDERSTAND': ("I could not understand what you mean, " +
                             "if you want to check weather something is Fake News, " +
                             "please, paste a link or a text here")
}

words_pt = {
    'NOTHING_WRONG': "Não parece ter nada de errado com esse conteúdo",
    'SORRY_ERROR': "Desculpe, um erro ocorreu, por favor, tente novamente mais tarde",
    'ALMOST_CERTAIN': "tenho quase certeza que é",
    'LOOKS_A_LOT_LIKE': "parece muito ser",
    'SEEMS_TO_BE': "parece ser",
    'EXTREMELY_BIASED': "conteúdo Extremamente Tendencioso",
    'COULD_NOT_UNDERSTAND': ("Eu não entendi o que você quis dizer, " +
                             "se você quer checar se algo é Fake News, " +
                             "por favor, cole um link ou texto aqui")
}

words_es = {
    'NOTHING_WRONG': "No parece haber nada de malo con este contenido",
    'SORRY_ERROR': "Lo sentimos, ocurrió un error. Inténtelo nuevamente",
    'ALMOST_CERTAIN': "estoy casi seguro de que esto es",
    'LOOKS_A_LOT_LIKE': "parece ser",
    'SEEMS_TO_BE': "parece ser",
    'EXTREMELY_BIASED': "Extremadamente Tienencioso",
    'COULD_NOT_UNDERSTAND': ("No pude entender lo que quieres decir, " +
                             "si quieres verificar si algo es Fake News, " +
                             "por favor, pega un enlace o un texto aquí")
}


def detect(text):
    try:
        return langdetect.detect(text)
    except Exception:
        return "en"


def translate(lang, word):
    if lang == 'pt':
        return words_pt[word]
    if lang == 'es':
        return words_es[word]
    return words_en[word]
