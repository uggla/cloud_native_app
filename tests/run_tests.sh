#!/bin/bash

set -x

export OS_USERNAME="Lab1"
export OS_PASSWORD="RocherIsADickhead"
export OS_AUTH_URL="http://10.11.50.7:5000/v2.0"
export OS_PROJECT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_TENANT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_SSH_USER="ubuntu"

cleanup() {
    eval $(docker-machine env manager)
    ./docker_services_rm.sh
}

trap "cleanup" ERR
set -eE

eval $(docker-machine env manager)
STACK_FILE="docker-compose-v3-testing.yml" ./docker_services.sh

for testfile in $(ls tests/testfiles | sort); do
    if [ -f "tests/testfiles/$testfile" ]; then
        echo "Running $testfile..."
        "tests/testfiles/$testfile"
    fi
done

trap "" ERR
set +eE

cleanup
