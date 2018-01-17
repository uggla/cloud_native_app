#!/bin/bash -xe

DOCKERID="$1"

if [ -z "$DOCKERID" ]; then
    exit 1
fi

docker kill "$DOCKERID"
docker rm "$DOCKERID"
