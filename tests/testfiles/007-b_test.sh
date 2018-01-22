#!/bin/bash -xe

set +e

while [ -z "$IP" ]; do
    sleep 10

    IP="$(docker-machine ip manager)"
    status="$?"

    if [ "$status" -ne 0 ]; then
        exit "$status"
    fi
done

echo "IP: $IP"

curl -s "http://$IP:8082" > /tmp/curl_output_header_b

diff -b /tmp/curl_output_header_b tests/testfiles/oracle_files/curl_header_b.json

status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi


rm /tmp/curl_output_header_b
