#!/usr/bin/env bash
set -e
REGISTRY="quay.io/keelson"
IMAGE_NAME="namespacer"
cd container
docker build -t ${IMAGE_NAME} .
cd --
IMAGE_ID=$(docker images  --quiet ${IMAGE_NAME})
docker tag ${IMAGE_ID} ${REGISTRY}/${IMAGE_NAME}
docker login ${REGISTRY}
docker push ${REGISTRY}/${IMAGE_NAME}
