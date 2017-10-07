Robinho
=======

## How to run

First you need to install the dependencies:

```
pip3 install -r requirements.txt
```

Then you can use the saved model to do predictions:

```
python3 . "notícia do mbl"
>> Extremely Biased

python3 . "notícia do neymar"
>> Legitimate
```

To retrain the model:

```
python3 . --retrain
```

To run tests:

```
python3 -m unittest tests/*_test.py
```
