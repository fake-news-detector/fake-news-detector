if [ ! -n "$FLOYDHUB_TOKEN" ]; then
    echo "FLOYDHUB_TOKEN variable not set"
    exit 1
fi;

echo "{\"username\": \"rchaves\", \"token\": \"$FLOYDHUB_TOKEN\"}" > ~/.floydconfig
url=$(floyd output -u)
job=${url/https:\/\/www.floydhub.com\//}

cd output
cp ../.floydexpt .
floyd data clone $job