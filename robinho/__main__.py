import sys
from robinho.model import Robinho
import robinho.server as server
import robinho.categories as categories
import robinho.bot as bot

robinho = Robinho()

if "--retrain" in sys.argv:
    robinho.train()
    print("Done!")
elif "--server" in sys.argv:
    bot.start()
    server.start()
else:
    predicted = robinho.predict(sys.argv[-2], sys.argv[-1])
    if len(predicted) > 0:
        top_prediction = max(predicted, key=lambda item: item['chance'])
        print(categories.names[top_prediction['category_id']])
    else:
        print("Legitimate")
