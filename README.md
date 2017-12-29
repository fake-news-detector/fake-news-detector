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

## Deploy

The deploy is made by CircleCI using docker on heroku.

Read more about deploying docker with heroku [on the oficial docs](https://devcenter.heroku.com/articles/container-registry-and-runtime).
