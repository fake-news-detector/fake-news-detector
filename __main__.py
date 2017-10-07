import sys
import robinho.model as robinho

categories = [
    "Legitimate", "Fake News", "Click Bait", "Extremely Biased", "Satire"
]

if "--retrain" in sys.argv:
    robinho.train()
else:
    predicted = robinho.predict([sys.argv[-1]])[0]
    print(categories[predicted - 1])
