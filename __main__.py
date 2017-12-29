import sys
from robinho.model import Robinho
import robinho.server as server

robinho = Robinho()

if "--retrain" in sys.argv:
    robinho.train()
    print("Done!")
elif "--server" in sys.argv:
    server.start()
