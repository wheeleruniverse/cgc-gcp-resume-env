#!/bin/bash

IMAGE=$(cat image.txt)
NAME="app/deploy.sh"

echo "$(date) :: ${NAME} :: started"

echo
echo "$(date) :: ${NAME} :: deploy '${IMAGE}'"
gcloud run deploy wheelersadvice --image ${IMAGE} --region us-central1

echo
echo "$(date) :: ${NAME} :: success"
