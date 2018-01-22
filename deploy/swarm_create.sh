#!/bin/bash -x

alias docker="sudo docker"

export OS_USERNAME="Lab1"
export OS_PASSWORD="$(cat $HOME/.os_prod_pwd)"
export OS_AUTH_URL="http://10.11.50.7:5000/v2.0"
export OS_PROJECT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_TENANT_ID="979788d1bf4246f7b19f9b4231088ea9"
export OS_FLAVOR_NAME="v1.m1.d5"
export OS_IMAGE_NAME="Ubuntu 16.04 \"Xenial Xerus\""
export OS_NETWORK_NAME="test"
export OS_SECURITY_GROUPS="default,testing"
export OS_SSH_USER="ubuntu"

WORKDIR="$(dirname $0)"

REGISTRY="registry.hp-lab1.local"
NB_AGENTS=2

rm -r "$HOME/.docker"

cleanup() {
    HOSTS="$(docker-machine ls -f "{{.Name}}")"

    if [ -n "$HOSTS" ]; then
        docker-machine rm -y $HOSTS
    fi
}

docker-machine create --engine-storage-driver overlay2 --driver openstack manager-prod
status="$?"

tries=0
until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
    docker-machine provision manager-prod
    status="$?"
    tries="$((tries+1))"
done

for i in $(seq 1 "$NB_AGENTS"); do
    docker-machine create --engine-storage-driver overlay2 --driver openstack agent-prod-"$i"
    status="$?"

    tries=0
    until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
        docker-machine provision agent-prod-"$i"
        status="$?"
        tries="$((tries+1))"
    done
done

set -e
trap "cleanup" ERR

MANAGER_IP="$(docker-machine ip manager-prod)"

scp -i  ~/.ssh/deploy-key.pem ubuntu@"$REGISTRY":/docker-registry/nginx/devdockerCA.crt /tmp

docker-machine scp /tmp/devdockerCA.crt manager-prod:/tmp

docker-machine ssh manager-prod <<'EOF'
sudo mkdir /usr/local/share/ca-certificates/docker-dev-cert
mv /tmp/devdockerCA.crt /usr/local/share/ca-certificates/docker-dev-cert
sudo update-ca-certificates
EOF

for i in $(seq 1 "$NB_AGENT"); do
    docker-machine scp /tmp/devdockerCA.crt agent-prod-"$i":/tmp

    docker-machine ssh agent-prod-"$i" <<'EOF'
sudo mkdir /usr/local/share/ca-certificates/docker-dev-cert
mv /tmp/devdockerCA.crt /usr/local/share/ca-certificates/docker-dev-cert
sudo update-ca-certificates
EOF
done

eval $(docker-machine env manager-prod)
docker swarm init
TOKEN="$(docker swarn join-token -q worker)"

for i in $(seq 1 "$NB_AGENT"); do
    eval $(docker-machine env agent-prod-"$i")
    docker swarm join --token "$TOKEN" manager-prod "$MANAGER_IP"
done

"$WORKDIR/docker_services.sh"
