.PHONY: build

build:
	docker build --build-arg FLOYDHUB_TOKEN=$$FLOYDHUB_TOKEN --build-arg CIRCLE_CI_TOKEN=$$CIRCLE_CI_TOKEN --cache-from registry.heroku.com/robinho/web:latest -t registry.heroku.com/robinho/web .

stylecheck: build
	docker run --rm registry.heroku.com/robinho/web flake8 robinho/

test: stylecheck
	docker run --rm registry.heroku.com/robinho/web python3 -m unittest

run: build
	docker run -p 8888:8888 --rm registry.heroku.com/robinho/web sh -c 'rm data/links.csv; python3 . --retrain && python3 . --server'

retrain:
	floyd run "pip3 install -r requirements.txt && python3 . --retrain && mv output/* /output/"

redeploy:
	curl -X POST https://circleci.com/api/v1/project/fake-news-detector/robinho/tree/master?circle-token=$$CIRCLE_CI_TOKEN