import robinho.bot.messages.welcome as welcome
import robinho.bot.messages.check_text as check_text


def start():
    print(welcome.respond())
    while True:
        message = input('> ')
        if message == 'exit':
            break

        print("\n" + check_text.respond(message) + "\n")
