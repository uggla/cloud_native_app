#!/bin/bash -xe

DOCKERID="$1"
TESTFILE="$2"
TESTNAME="$(basename "$TESTFILE")"

if [ -z "$DOCKERID" -o -z "$TESTFILE" ]; then
    exit 1
fi

docker cp "$TESTFILE" "$DOCKERID:/workdir"
docker exec "$DOCKERID" "/workdir/$TESTNAME"
docker exec "$DOCKERID" rm "/workdir/$TESTNAME"
