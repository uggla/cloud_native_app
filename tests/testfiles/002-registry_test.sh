#!/bin/bash -xe

set +e

if [ ! -f /usr/local/share/ca-certificates/docker-dev-cert/devdockerCA.crt]; then
  sudo mkdir -p /usr/local/share/ca-certificates/docker-dev-cert/
  sudo scp -i ~/.ssh/deploy-key.pem ubuntu@registry.hp-lab1.local:/docker-registry/nginx/devdockerCA.crt /usr/local/share/ca-certificates/docker-dev-cert
  sudo update ca-certificates
  sudo systemctl restart docker
  sleep 10
fi

curl  "https://registry.hp-lab1.local:5043/v2" > /tmp/curl_registry_output

diff -b /tmp/curl_registry_output tests/testfiles/oracle_files/curl_result_registry.json

status="$?"


if [ "$status" -ne 0 ]; then
    exit "$status"
fi

rm /tm p/curl_registry_output
