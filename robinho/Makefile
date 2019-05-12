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
	curl -X POST -d build_parameters[CIRCLE_JOB]=robinho -d build_parameters[FORCE_DEPLOY]=true https://circleci.com/api/v1.1/project/github/fake-news-detector/fake-news-detector/tree/master?circle-token=$$CIRCLE_CI_TOKEN

retrain:
	mv train_data/links.csv train_data/links.copy.csv; python3 . --retrain; mv train_data/links.copy.csv train_data/links.csv
