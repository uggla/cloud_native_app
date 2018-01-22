#!/bin/bash -xe

set +e

while [ -z "$IP" ]; do

    IP="$(docker-machine ip manager)"
    status="$?"

    if [ "$status" -ne 0 ]; then
        exit "$status"
    fi
done

echo "IP: $IP"

curl -s "http://$IP:8090" > /tmp/curl_output_header_w

diff -b /tmp/curl_output_header_w tests/testfiles/oracle_files/curl_header_w.json

status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi


rm /tmp/curl_output_header_b
