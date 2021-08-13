#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "${0}")/config.sh"

"$(dirname "${0}")/auth.sh"

echo '--- Import and publish Elasticsearch image'

export ES_IMAGE="gcr.io/elastic-kibana-184716/demo/elasticsearch:$DEPLOYMENT_NAME-$(git rev-parse HEAD)"

DOCKER_EXPORT_URL=$(curl https://storage.googleapis.com/kibana-ci-es-snapshots-daily/$DEPLOYMENT_VERSION/manifest-latest-verified.json | jq -r '.archives | .[] | select(.platform=="docker") | .url')
docker import "$DOCKER_EXPORT_URL" "$ES_IMAGE"
docker push "$ES_IMAGE"

echo '--- Prepare yaml'

TEMPLATE=$(envsubst < "$(dirname "${0}")/init.yml")

echo "$TEMPLATE"

echo '--- Deploy yaml'
echo "$TEMPLATE" | kubectl apply -f -
