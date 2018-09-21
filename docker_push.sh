#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push djreynolds1/scratch-python:latest
docker push djreynolds1/scratch-python:3.7
docker push djreynolds1/scratch-python:3.7.0
