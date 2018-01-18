#!/bin/bash -xe

GITPATH=".."
VPNPATH="~/VPN"
WORKDIR="/workdir"

docker pull treens/hp-testenv &> /dev/null

DOCKERID="$(docker run -d --privileged --cap-add=NET_ADMIN treens/hp-testenv sleep infinity)" &> /dev/null

docker cp "$VPNPATH" "$DOCKERID":/root &> /dev/null
docker cp ~/.ssh/deploy-key.pem "$DOCKERID":/root &> /dev/null
docker exec "$DOCKERID" chmod 600 /root/deploy-key.pem
docker cp "$GITPATH" "$DOCKERID:$WORKDIR" &> /dev/null
docker exec -dw /root/VPN "$DOCKERID" openvpn /root/VPN/vpnlab2017.conf &> /dev/null

#Wait for the VPN to be connected
sleep 10 &> /dev/null

echo -n "$DOCKERID"
