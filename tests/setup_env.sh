#!/bin/bash -xe

GITPATH=".."
WORKDIR="/workdir"

DOCKERID="$(docker run -d --privileged --cap-add=NET_ADMIN treens/hp-testenv sleep infinity)" &> /dev/null

docker exec "$DOCKERID" mkdir -p "$WORKDIR" &> /dev/null
docker cp ~/VPN "$DOCKERID":/root &> /dev/null
docker cp "$GITPATH" "$DOCKERID:$WORKDIR" &> /dev/null
docker exec -d "$DOCKERID" openvpn /root/VPN/vpnlab2017.conf &> /dev/null

#Wait for the VPN to be connected
sleep 10 &> /dev/null

echo -n "$DOCKERID"
