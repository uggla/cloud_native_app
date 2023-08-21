#!/bin/bash

# Script to run the CNA as docker services on swarm

#
# You need to provide your Registry address here:
#REGISTRY=registry.uggla.fr
REGISTRY=lab7-2.labossi.hpintelco.org:5500
KEYSTONE=labossi.hpintelco.org
MYSQL_ROOT_PASSWORD=toto
MYSQL_DATABASE=prestashop
MYSQL_USER=prestashop
MYSQL_PASSWORD=prestashop1234
W2_APIKEY=blakey
W2_TO=machin@bidule.com
W2_DOMAIN=domain


# Patch docker-compose-v3.yaml to pass our variables
sed -i "s/##MYSQL_ROOT_PASSWORD##/$MYSQL_ROOT_PASSWORD/" docker-compose-v3.yml
sed -i "s/##MYSQL_DATABASE##/$MYSQL_DATABASE/" docker-compose-v3.yml
sed -i "s/##MYSQL_USER##/$MYSQL_USER/" docker-compose-v3.yml
sed -i "s/##MYSQL_PASSWORD##/$MYSQL_PASSWORD/" docker-compose-v3.yml
sed -i "s/##W2_APIKEY##/$W2_APIKEY/" docker-compose-v3.yml
sed -i "s/##W2_TO##/$W2_TO/" docker-compose-v3.yml
sed -i "s/##W2_DOMAIN##/$W2_DOMAIN/" docker-compose-v3.yml
sed -i "s/##REGISTRY##/$REGISTRY/" docker-compose-v3.yml

# Patch the p and w1 conf files to point to the SWIFT instance
sed -i "s/keystone/$KEYSTONE/" `dirname $0`/microservices/p/p.conf
sed -i "s/keystone/$KEYSTONE/" `dirname $0`/microservices/w1/w1.conf

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
    docker run -it -d -p 8080:8080 $ENVOPT -v /var/run/docker.sock:/var/run/docker.sock --name visualizer dockersamples/visualizer
fi

# Build images if not done yet
for a in web i b p s w w1 w2 db; do
	img=`docker images | grep -E "^cloud_native_app_$a "`
	if [ _"$img" = _"" ]; then
		docker-compose build
	fi
done

# Push images in Registry if not done yet
for a in web i b p s w w1 w2 db; do
	img=`docker images | grep -E "^$REGISTRY/cloud_native_app_$a "`
	if [ _"$img" = _"" ]; then
		docker tag cloud_native_app_$a $REGISTRY/cloud_native_app_$a
		docker push $REGISTRY/cloud_native_app_$a
	fi
done

# Launch services - Should be replaced by docker-compose v3 once available
#for a in web i b p s w w1 w2 db; do
#	if [ $a = "web" ]; then
#		OPT="--publish 80:80"
#	elif [ $a = "w2" ]; then
#		OPT="--env W2_APIKEY=blakey --env W2_TO=machin@bidule.com --env W2_DOMAIN=domain"
#	elif [ $a = "db" ]; then
#		OPT="--env MYSQL_ROOT_PASSWORD=toto --env MYSQL_DATABASE=prestashop --env MYSQL_USER=prestashop --env MYSQL_PASSWORD=prestashop1234" 
#	else
#		OPT=""
#	fi
#
#	svc=`docker service ls | grep -E " $a "`
#	if [ _"$svc" = _"" ]; then
#		docker service create --name $a --network cnalan $OPT $REGISTRY/cloud_native_app_$a
#	fi
#done

docker stack deploy -c docker-compose-v3.yml cna
sleep 5
docker service ls
