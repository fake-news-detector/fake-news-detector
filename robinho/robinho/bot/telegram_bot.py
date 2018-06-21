import os
import robinho.bot.messages.welcome as welcome
import robinho.bot.messages.check_text as check_text
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
from robinho.bot.tracking import track_event


def telegram_message(event, text_fn):
    def send_message(bot, update):
        track_event("telegram_bot", event, update.message.chat_id)
        bot.send_message(chat_id=update.message.chat_id,
                         disable_web_page_preview=True,
                         text=text_fn(update.message.text))
    return send_message


def add_handlers(dispatcher):
    handlers = [
        CommandHandler('start', telegram_message("/start", welcome.respond)),
        MessageHandler(Filters.text, telegram_message(
            "interaction", check_text.respond))
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
