source floydhub_scripts/credentials.sh

url=$(floyd output -u)
job=${url/https:\/\/www.floydhub.com\//}

cd output
cp ../.floydexpt .
floyd data clone $job