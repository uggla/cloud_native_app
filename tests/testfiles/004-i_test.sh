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

curl -s "http://$IP:8080" > /tmp/curl_output_header_i

diff -b /tmp/curl_output_header_i tests/testfiles/oracle_files/curl_header_i.json

status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi

curl -s "http://$IP:8080/user/1" > /tmp/curl_output_i

diff -b /tmp/curl_output_i tests/testfiles/oracle_files/curl_result_i.json

status="$?"


if [ "$status" -ne 0 ]; then
    exit "$status"
fi

rm /tmp/curl_output_header_i
rm /tmp/curl_output_i
