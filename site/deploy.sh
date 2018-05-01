set -e

SHA=`git rev-parse --verify HEAD`

git clone git@github.com:fake-news-detector/fake-news-detector.github.io.git fake-news-detector.github.io
rm -rf fake-news-detector.github.io/*
rm -rf fake-news-detector.github.io/**/*
cp -R build/* fake-news-detector.github.io
cd fake-news-detector.github.io

echo "fakenewsdetector.org" >> CNAME
echo "www.fakenewsdetector.org" >> CNAME

git config user.name "Circle CI"
git config user.email "circle-ci@fakenewsdetector.org"

git add -A
git commit -m "Deploy to GitHub Pages: ${SHA}" || echo "nothing to commit"
git push origin master
