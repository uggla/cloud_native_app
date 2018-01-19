#!/bin/bash -xe

DB_ROOT_PWD="test_root_pwd"
DB_NAME="prestashop"
DB_USER="prestashop"
DB_PWD="prestashop1234"

cd templates/db_i

heat stack-create -f db_i.yml \
    -P "key_name=deploy-key;network=test;sg=testing;db_root_password=$DB_ROOT_PWD;db_name=$DB_NAME;db_user=$DB_USER;db_password=$DB_PWD" \
    db

# Wait for the VM
sleep 30

set +e

while [ -z "$IP" ]; do
    sleep 10

    IP="$(heat output-show db instance_ip | sed 's/"//g')"
    status="$?"

    if [ "$status" -ne 0 ]; then
        heat stack-delete -y db
        exit "$status"
    fi
done

echo "IP: $IP"

# Wait for the service
sleep 300

ssh -oStrictHostKeyChecking=no -i /root/deploy-key.pem ubuntu@10.11.53.16 mysql -h "$IP" -u "root" -p"$DB_ROOT_PWD" <<'EOF'
exit
EOF
status="$?"

if [ "$status" -ne 0 ]; then
    heat stack-delete -y db
    exit "$status"
fi

ssh -oStrictHostKeyChecking=no -i /root/deploy-key.pem ubuntu@10.11.53.16 mysql -h "$IP" -u "$DB_USER" -p"$DB_PWD" -D "$DB_NAME" <<'EOF'
exit
EOF
status="$?"

if [ "$status" -ne 0 ]; then
    heat stack-delete -y db
    exit "$status"
fi

ssh -oStrictHostKeyChecking=no -i /root/deploy-key.pem ubuntu@10.11.53.16 curl "http://$IP:8080"
status="$?"

if [ "$status" -ne 0 ]; then
    heat stack-delete -y db
    exit "$status"
fi

ssh -oStrictHostKeyChecking=no -i /root/deploy-key.pem ubuntu@10.11.53.16 curl -s "http://$IP:8080/user/1" > /tmp/curl_output

diff -b /tmp/curl_output ../../tests/testfiles/oracle_files/curl_result_i.json

status="$?"


if [ "$status" -ne 0 ]; then
    heat stack-delete -y db
    exit "$status"
fi

heat stack-delete -y db
