.PHONY: build

build:
	docker build --cache-from registry.heroku.com/robinho/web:latest -t registry.heroku.com/robinho/web .

test: build
	docker run --rm registry.heroku.com/robinho/web python3 -m unittest

run: build
	docker run -p 8888:8888 --rm registry.heroku.com/robinho/web sh -c 'rm data/links.csv; python3 . --retrain && python3 . --server'

