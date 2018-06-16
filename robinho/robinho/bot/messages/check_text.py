from robinho.model import Robinho

robinho = Robinho()


def certainty_level(chance):
    rebalancedChance = (chance * 100 - 50) * 2
    if rebalancedChance >= 66:
        return "I'm almost certain it is"
    elif rebalancedChance >= 33:
        return "Looks a lot like"
    else:
        return "Looks like"


def respond(text):
    predicted = robinho.predict("", text, "")

    lines = []
    if predicted['fake_news']:
        lines.append(certainty_level(predicted['fake_news']) + " Fake News")
    if predicted['extremely_biased']:
        lines.append(certainty_level(
            predicted['extremely_biased']) + " Extremely Biased")
    if predicted['clickbait']:
        lines.append(certainty_level(predicted['clickbait']) + " Clickbait")

    if lines == []:
        lines.append(
            "There doesn't seem to be anything wrong with this content")

    return "\n".join(lines)
