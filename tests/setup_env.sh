#!/bin/bash -xe

GITPATH=".."
VPNPATH="$HOME/VPN"
WORKDIR="/workdir"

docker pull treens/hp-testenv 1>&2

DOCKERID="$(docker run -d --privileged --cap-add=NET_ADMIN treens/hp-testenv sleep infinity)" 1>&2

docker cp "$VPNPATH" "$DOCKERID":/root 1>&2
docker cp ~/.ssh/deploy-key.pem "$DOCKERID":/root 1>&2
docker exec "$DOCKERID" chmod 600 /root/deploy-key.pem
docker cp "$GITPATH" "$DOCKERID:$WORKDIR" 1>&2
docker exec -dw /root/VPN "$DOCKERID" openvpn /root/VPN/vpnlab2017.conf 1>&2

#Wait for the VPN to be connected
sleep 10 1>&2

docker exec -d "$DOCKERID" ssh -oStrictHostKeyChecking=no -4i /root/deploy-key.pem -L 8004:10.11.50.7:8004 ubuntu@10.11.53.16 sleep infinity 1>&2
docker exec -d "$DOCKERID" ssh -oStrictHostKeyChecking=no -4i /root/deploy-key.pem -L 5000:10.11.50.7:5000 ubuntu@10.11.53.16 sleep infinity 1>&2

#Wait for the SSH port redirections to work
sleep 10 1>&2

echo -n "$DOCKERID"
