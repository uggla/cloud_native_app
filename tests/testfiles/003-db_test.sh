#!/bin/bash -xe

DB_ROOT_PWD="toto"
DB_NAME="prestashop"
DB_USER="prestashop"
DB_PWD="prestashop1234"

set +e

while [ -z "$IP" ]; do

    IP="$(docker-machine ip manager)"
    status="$?"

    if [ "$status" -ne 0 ]; then
        exit "$status"
    fi
done

echo "IP: $IP"

mysql -h "$IP" -u "root" -p"$DB_ROOT_PWD" <<'EOF'
exit
EOF
status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi

mysql -h "$IP" -u "$DB_USER" -p"$DB_PWD" -D "$DB_NAME" <<'EOF'
exit
EOF
status="$?"

if [ "$status" -ne 0 ]; then
    exit "$status"
fi
