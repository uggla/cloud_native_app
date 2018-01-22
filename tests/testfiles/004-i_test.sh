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

curl -s "http://$IP:8080/user/1" > /tmp/curl_output

diff -b /tmp/curl_output tests/testfiles/oracle_files/curl_result_i.json

status="$?"


if [ "$status" -ne 0 ]; then
    exit "$status"
fi

rm /tm p/curl_output
