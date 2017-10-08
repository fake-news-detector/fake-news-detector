import sys
import robinho.model as robinho
import robinho.server as server

categories = [
    "Legitimate", "Fake News", "Click Bait", "Extremely Biased", "Satire"
]

if "--retrain" in sys.argv:
    robinho.train()
elif "--server" in sys.argv:
    server.start()
else:
    predicted = robinho.predict([sys.argv[-1]])[0]
    print(categories[predicted - 1])
