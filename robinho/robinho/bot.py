from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
import logging
import os

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)


def welcome(bot, update):
    welcome_message = """
🇬🇧 Hello! I am Robinho, I'm a robot that tries to detect hoaxes and fake news, paste a text or a link here to check

🇧🇷 Olá! Eu sou o Robinho, eu sou um robô que tenta detectar boatos e fake news, cole um texto ou link aqui para checar

🇪🇸 ¡Hola! Yo soy Robinho, soy un robot que intenta detectar rumores y fake news, pega un texto o enlace aquí para verificar
"""
    bot.send_message(chat_id=update.message.chat_id, text=welcome_message)


def echo(bot, update):
    bot.send_message(chat_id=update.message.chat_id,
                     text="Echo: " + update.message.text)


def add_handlers(dispatcher):
    dispatcher.add_handler(MessageHandler(Filters.text, echo))
    dispatcher.add_handler(CommandHandler('start', welcome))


def start():
    telegram_token = os.getenv("TELEGRAM_TOKEN")
    if telegram_token:
        updater = Updater(token=telegram_token)
        add_handlers(updater.dispatcher)

        updater.start_polling()
        print('Bot listening to Telegram')
    else:
        print('TELEGRAM_TOKEN not set, bot will not run. Please set a TELEGRAM_TOKEN to start the Telegram Bot')
