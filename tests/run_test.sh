#!/bin/bash -xe

DOCKERID="$1"
TESTFILE="$2"
TESTNAME="$(basename "$TESTFILE")"
WORKDIR="/workdir"

if [ -z "$DOCKERID" -o -z "$TESTFILE" ]; then
    exit 1
fi

docker cp "$TESTFILE" "$DOCKERID:$WORKDIR"
docker exec -w "$WORKDIR" "$DOCKERID" "$WORKDIR/$TESTNAME"
docker exec "$DOCKERID" rm "$WORKDIR/$TESTNAME"
