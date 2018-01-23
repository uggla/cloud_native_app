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

curl -s "http://$IP:8083" > /tmp/curl_output_header_p

diff -b /tmp/curl_output_header_p tests/testfiles/oracle_files/curl_header_p.json

status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi


rm /tmp/curl_output_header_p
