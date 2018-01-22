#!/bin/bash

# Script to run the CNA as docker services on swarm

set -x

if [ -z "$STACK_FILE" ]; then
    STACK_FILE="docker-compose-v3.yml"
fi

REGISTRY=registry.hp-lab1.local:5043
KEYSTONE=
MYSQL_ROOT_PASSWORD=toto
MYSQL_DATABASE=prestashop
MYSQL_USER=prestashop
MYSQL_PASSWORD=prestashop1234
W2_APIKEY="$(cat "$HOME/.mailgunkey")"
W2_TO="pierre.franco@grenoble-inp.org"
W2_DOMAIN=hp1-lab.local
WORKDIR="$(dirname $0)"

# Patch docker-compose-v3.yaml to pass our variables
cp $STACK_FILE $STACK_FILE.old

sed -i "s/##MYSQL_ROOT_PASSWORD##/$MYSQL_ROOT_PASSWORD/" $STACK_FILE
sed -i "s/##MYSQL_DATABASE##/$MYSQL_DATABASE/" $STACK_FILE
sed -i "s/##MYSQL_USER##/$MYSQL_USER/" $STACK_FILE
sed -i "s/##MYSQL_PASSWORD##/$MYSQL_PASSWORD/" $STACK_FILE
sed -i "s/##W2_APIKEY##/$W2_APIKEY/" $STACK_FILE
sed -i "s/##W2_TO##/$W2_TO/" $STACK_FILE
sed -i "s/##W2_DOMAIN##/$W2_DOMAIN/" $STACK_FILE
sed -i "s/##REGISTRY##/$REGISTRY/" $STACK_FILE

# Patch the p and w1 conf files to point to the SWIFT instance
cp "$WORKDIR/microservices/p/p.conf" "$WORKDIR/microservices/p/p.conf.old"
cp "$WORKDIR/microservices/w1/w1.conf" "$WORKDIR/microservices/w1/w1.conf.old"

sed -i "s/keystone/$KEYSTONE/" "$WORKDIR/microservices/p/p.conf"
sed -i "s/keystone/$KEYSTONE/" "$WORKDIR/microservices/w1/w1.conf"

# Start vizualizer on port 8080
which docker-machine > /dev/null 2>&1
if [ $? -ne 0 ]; then
	ENVOPT=""
else
	ENVOPT="-e HOST=$(docker-machine ls | head -2 | grep -v NAME | awk '{print $5}' | sed 's#tcp://##' | sed 's#:2376##') -e PORT=8080"
fi

docker ps | grep visualizer > /dev/null 2>&1
if [ $? -ne 0 ]; then
    docker ps -a | grep visualizer && docker rm visualizer
    docker run -it -d -p 4242:4242 $ENVOPT -v /var/run/docker.sock:/var/run/docker.sock --name visualizer dockersamples/visualizer
fi

# Determine which images to rebuild and push
for svc in web i b p s w w1 w2 db; do
    reg_date="$(curl -s https://registry.hp-lab1.local:5043/v2/cloudnativeapp_$svc/manifests/latest)"
    reg_date="$(echo "$reg_date" | jq -r '[.history[]]|map(.v1Compatibility|fromjson|.created)|sort|reverse|.[0]')"
    status="$?"

    # Image hasn't been pushed yet
    if [ "$status" -ne 0 ]; then
        BUILD_LIST=(${BUILD_LIST[@]} $svc)
        continue
    fi

    reg_date="$(date -d "$reg_date" "+%Y%m%d%H%M%S")"
    git_date="$(date -d "$(git log -1 --format=%cI "microservices/$svc")" "+%Y%m%d%H%M%S")"

    if [ "$git_date" -gt "$reg_date" ]; then
        BUILD_LIST=(${BUILD_LIST[@]} $svc)
    fi
done

# Build and push the images
for svc in ${BUILD_LIST[@]}; do
    status=1
    tries=0

    until [ "$status" -eq 0 -o "$tries" -eq 5 ]; do
        docker-compose build "$svc"
        tries="$((tries+1))"
    done

    docker tag "cloudnativeapp_$svc" "$REGISTRY/cloudnativeapp_$svc"
    docker push "$REGISTRY/cloudnativeapp_$svc"
done

docker stack deploy -c $STACK_FILE cna

# Wait for services to start
timeout=0

until [ -z "$(docker service ls | tail -n +2 | tr -s ' ' | cut -d' ' -f 4 | sed -E 's|([[:digit:]]+)/\1||')" -o "$timeout" -ge 60 ]; do
    sleep 5
    timeout="$((timeout+5))"
done

docker service ls
