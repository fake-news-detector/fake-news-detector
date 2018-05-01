set -e

nrsysmond-config --set license_key=$NEW_RELIC_LICENSE_KEY
nrsysmond -F -c /etc/newrelic/nrsysmond.cfg &

diesel migration run

ROCKET_PORT=$PORT fake-news-api
