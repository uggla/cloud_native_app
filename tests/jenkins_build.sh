#!/bin/bash -xe

WORKDIR="/home/ubuntu/$BUILD_TAG"

cleanup() {
    docker kill "$DOCKER_ID"
    docker rm "$DOCKER_ID"
}

docker pull treens/hp-testenv

DOCKER_ID="$(docker run --privileged --cap-add=NET_ADMIN -d treens/hp-testenv sleep infinity)"

set -eE

trap "cleanup" ERR

docker cp -L "$HOME/VPN" "$DOCKER_ID:/root/VPN"
docker exec -dw /root/VPN "$DOCKER_ID" openvpn vpnlab2017.conf

# Wait for the VPN client to get connected
sleep 10

docker cp -L "$(dirname $0)/.." "$DOCKER_ID:/root/CNA"
docker cp -L "$HOME/.ssh/deploy-key.pem" "$DOCKER_ID:/root"

docker exec -i "$DOCKER_ID" bash -xe <<EOF

scp -oStrictHostKeyChecking=no -ri ~/deploy-key.pem /root/CNA ubuntu@10.11.53.16:"$WORKDIR"
ssh -oStrictHostKeyChecking=no -i ~/deploy-key.pem ubuntu@10.11.53.16 "cd $WORKDIR; tests/run_tests.sh"

EOF

trap "" ERR
set +eE

cleanup
