#!/bin/bash -xe

alias docker-machine="sudo docker-machine"
alias docker="sudo docker"

export OS_USERNAME="Lab1"
export OS_PASSWORD="RocherIsADickhead"
export OS_AUTH_URL="http://10.11.50.7:5000/v2.0"
export OS_PROJECT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_TENANT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_FLAVOR_NAME="v1.m1.d5"
export OS_IMAGE_NAME="Ubuntu 16.04 \"Xenial Xerus\""
export OS_NETWORK_NAME="test"
export OS_SECURITY_GROUPS="default,testing"
export OS_SSH_USER="ubuntu"

rm -r "$HOME/.docker"

cleanup() {
    HOSTS="$(docker-machine ls -f "{{.Name}}")"

    if [ -n "$HOSTS" ]; then
        docker-machine rm -y $HOSTS
    fi
}

docker-machine create --engine-storage-driver overlay2 --driver openstack manager
status="$?"

tries=0
until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
    docker-machine provision manager
    status="$?"
    tries="$((tries+1))"
done

docker-machine create --engine-storage-driver overlay2 --driver openstack agent-1
status="$?"

tries=0
until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
    docker-machine provision manager
    status="$?"
    tries="$((tries+1))"
done

docker-machine create --engine-storage-driver overlay2 --driver openstack agent-2
status="$?"

tries=0
until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
    docker-machine provision manager
    status="$?"
    tries="$((tries+1))"
done

set -eE
trap "cleanup" ERR

MANAGER_IP="$(docker-machine ip manager)"

scp -i  ~/.ssh/deploy-key.pem ubuntu@192.168.6.13:/docker-registry/nginx/devdockerCA.crt /tmp

docker-machine scp /tmp/devdockerCA.crt agent-1:/tmp
docker-machine scp /tmp/devdockerCA.crt agent-2:/tmp

docker-machine ssh agent-1 <<'EOF'
sudo mkdir /usr/local/share/ca-certificates/docker-dev-cert
mv /tmp/devdockerCA.crt /usr/local/share/ca-certificates/docker-dev-cert
sudo update-ca-certificates
EOF

docker-machine ssh agent-2 <<'EOF'
sudo mkdir /usr/local/share/ca-certificates/docker-dev-cert
mv /tmp/devdockerCA.crt /usr/local/share/ca-certificates/docker-dev-cert
sudo update-ca-certificates
EOF

eval $(docker-machine env manager)
docker swarm init
TOKEN="$(docker swarn join-token -q worker)"

eval $(docker-machine env agent-1)
docker swarm join --token "$TOKEN" manager "$MANAGER_IP"

eval $(docker-machine env agent-2)
docker swarm join --token "$TOKEN" manager "$MANAGER_IP"

./docker_services.sh

cd ..

for testfile in $(ls tests/testfiles | sort); do
    if [ -f "tests/testfiles/$testfile" ]; then
        echo "Running $testfile..."
        "tests/testfiles/$testfile"
    fi
done

cd tests

# Remove the swarm agents

trap "" ERR
set +eE

cleanup
