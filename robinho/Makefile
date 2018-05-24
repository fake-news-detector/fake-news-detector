.PHONY: build

build:
	docker build --build-arg CACHEBUST=$$(date +%s) -t fakenewsdetector/robinho .

stylecheck:
	docker run -it --rm fakenewsdetector/robinho flake8 robinho/

test: stylecheck
	docker run -it --rm fakenewsdetector/robinho python3 -m unittest

run:
	docker run -p 8888:8888 -it --rm fakenewsdetector/robinho

redeploy:
	curl -X POST https://circleci.com/api/v1/project/fake-news-detector/robinho/tree/master?circle-token=$$CIRCLE_CI_TOKEN

retrain:
	rm train_data/links.csv; python3 . --retrain