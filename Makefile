.PHONY: build

build:
	docker build --build-arg FLOYDHUB_TOKEN=$$FLOYDHUB_TOKEN -t fakenewsdetector/robinho .

stylecheck: build
	docker run --rm fakenewsdetector/robinho flake8 robinho/

test: stylecheck
	docker run --rm fakenewsdetector/robinho python3 -m unittest

run: build
	docker run -p 8888:8888 --rm fakenewsdetector/robinho sh -c 'rm data/links.csv; python3 . --retrain && python3 . --server'

retrain:
	bash floydhub_scripts/retrain.sh

redeploy:
	curl -X POST https://circleci.com/api/v1/project/fake-news-detector/robinho/tree/master?circle-token=$$CIRCLE_CI_TOKEN