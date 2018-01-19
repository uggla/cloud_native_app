#!/bin/bash -xe

DOCKERID="$1"
WORKDIR="/workdir"

if [ -z "$DOCKERID" ]; then
    exit 1
fi

docker exec -iw "$WORKDIR" "$DOCKERID" bash -e <<'EOF'
export OS_USERNAME="Lab1"
export OS_PASSWORD="RocherIsADickhead"
export OS_AUTH_URL="http://127.0.0.1:5000"
export OS_PROJECT_ID="979788d1bf4246f7b19f9b4231088ea9"
export HEAT_URL="http://127.0.0.1:8004/v1/$OS_PROJECT_ID"

for testfile in $(ls tests/testfiles | sort); do
    if [ -f "$testfile" ]; then
        echo "Running $testfile..."
        "tests/testfiles/$testfile"
    fi
done
EOF
