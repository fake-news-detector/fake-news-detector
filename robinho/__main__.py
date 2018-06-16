print("Loading models...")

import sys
from robinho.model import Robinho
import robinho.server as server
import robinho.bot.telegram_bot as telegram_bot
import robinho.bot.terminal_bot as terminal_bot

robinho = Robinho()

print("Done!")

if "--retrain" in sys.argv:
    robinho.train()
    print("Done!")
elif "--server" in sys.argv:
    telegram_bot.start()
    server.start()
else:
    terminal_bot.start()
