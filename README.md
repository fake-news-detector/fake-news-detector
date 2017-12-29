[![Build Status][ci-svg]][ci-url]

[ci-svg]: https://circleci.com/gh/fake-news-detector/robinho.svg?style=shield
[ci-url]: https://circleci.com/gh/fake-news-detector/robinho

# Robinho

## JSON API endpoints

The JSON API is currently running under the url https://robinho.fakenewsdetector.org/

### Predictions

You can predict the category of a news by calling:

`GET /predict?title=string&content=string`

Response format:

`{ predictions: [{ category_id: int, chance: float }] }`

## Running

### Without Docker

You will need Python 3 with pip, then you can install the dependencies:

```sh
pip3 install -r requirements.txt
```

Now you can retrain the model:

```sh
python3 . --retrain
```

Then use the saved model to do predictions, by passing the news title and body:

```sh
python3 . "Chora bandidagem" "Chora turma dos direitos humanos. Michel Temer acaba de sancionar..."
>> Extremely Biased

python3 . "Pato rebate provocação de Neymar com foto" "Neymar e Alexandre Pato resolveram brincar com os cabelos um do outro..."
>> Legitimate
```

#### Running

To run the server:

```sh
python3 . --server
```

#### Test Suite

You can run all tests with:

```sh
python3 -m unittest
```

### With Docker

#### Running

```sh
make run
```

#### Test Suite

```sh
make test
```

## Deploy

The deploy is made by CircleCI using docker on heroku.

Read more about deploying docker with heroku [on the oficial docs](https://devcenter.heroku.com/articles/container-registry-and-runtime).
