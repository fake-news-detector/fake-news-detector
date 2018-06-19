import time
print("Loading models...")
start = time.time()
import sys
import robinho.server as server
import robinho.bot.telegram_bot as telegram_bot
import robinho.bot.terminal_bot as terminal_bot
import robinho.bot.messages.chitchat as chitchat
from robinho.model import Robinho
from robinho.utils import current_ram

end = time.time()
print("Done! Models loaded in", "{:.1f}".format(end - start),
      "seconds. Using", current_ram(), "of RAM")

robinho = Robinho()

if "--retrain" in sys.argv:
    robinho.train()
    chitchat.train()
    print("Done!")
elif "--server" in sys.argv:
    telegram_bot.start()
    server.start()
else:
    terminal_bot.start()
