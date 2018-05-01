docker pull fakenewsdetector/api
docker build --cache-from fakenewsdetector/api -t fakenewsdetector/api .
docker run --rm fakenewsdetector/api cargo test

if [ "${CIRCLE_BRANCH}" == "master" ]; then
    docker push fakenewsdetector/api

    docker tag fakenewsdetector/api registry.heroku.com/fake-news-detector-api/web
    docker push registry.heroku.com/fake-news-detector-api/web
fi