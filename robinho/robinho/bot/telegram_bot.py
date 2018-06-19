import os
import robinho.bot.messages.welcome as welcome
import robinho.bot.messages.check_text as check_text
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters


def telegram_message(text_fn):
    return (lambda bot, update:
            bot.send_message(chat_id=update.message.chat_id,
                             text=text_fn(update.message.text)))


def add_handlers(dispatcher):
    handlers = [
        CommandHandler('start', telegram_message(welcome.respond)),
        MessageHandler(Filters.text, telegram_message(check_text.respond))
    ]
    for handler in handlers:
        dispatcher.add_handler(handler)


def start():
    telegram_token = os.getenv("TELEGRAM_TOKEN")
    if telegram_token:
        updater = Updater(token=telegram_token)
        add_handlers(updater.dispatcher)

        updater.start_polling()
        print('Bot listening to Telegram')
    else:
        print('TELEGRAM_TOKEN not set, bot will not run. Please set a TELEGRAM_TOKEN to start the Telegram Bot')
