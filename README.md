[![Build Status][ci-svg]][ci-url]

[ci-svg]: https://circleci.com/gh/fake-news-detector/robinho.svg?style=shield
[ci-url]: https://circleci.com/gh/fake-news-detector/robinho

Robinho
=======

## Running

### With Docker

#### Running

```sh
make run
```

#### Test Suite

```sh
make test
```

### Without Docker

First you need to install the dependencies:

#### Setup

```sh
pip3 install -r requirements.txt
```

Then you can use the saved model to do predictions:

```sh
python3 . "notícia do mbl"
>> Extremely Biased

python3 . "notícia do neymar"
>> Legitimate
```

To retrain the model:

```sh
python3 . --retrain
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

## JSON API endpoints

The JSON API is currently running under the url https://robinho.herokuapp.com/

### Predictions

You can predict the category of a news by calling:

`GET /predict?title=string`

Response format:

`{ predictions: [{ category_id: int, chance: float }] }`

## How to run

To run tests:

## Deploy

Read more about deploying docker with heroku [on the oficial docs](https://devcenter.heroku.com/articles/container-registry-and-runtime).
