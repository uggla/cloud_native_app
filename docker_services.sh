#!/bin/bash

# Script to run the CNA as docker services on swarm

#
# You need to provide your Registry address here:
#REGISTRY=uggla
REGISTRY=lab7-2.labossi.hpintelco.org:5500
KEYSTONE=labossi.hpintelco.org
WEB=`hostname`
MYSQL_ROOT_PASSWORD=toto
MYSQL_DATABASE=prestashop
MYSQL_USER=prestashop
MYSQL_PASSWORD=prestashop1234
W2_APIKEY=blakey
W2_TO=machin@bidule.com
W2_DOMAIN=domain


# Patch docker-compose-v3.yaml to pass our variables
sed -i "s/##MYSQL_ROOT_PASSWORD##/$MYSQL_ROOT_PASSWORD/g" docker-compose-v3.yml

# Patch the javascript for the internal URLs to use
# the swarm leader as an entry point for internal micro-services
sed "s/localhost/$WEB/" `dirname $0`/web/templates/config.js.docker

# Patch the p and w1 conf files to point to the SWIFT instance
sed "s/keystone/$KEYSTONE/" `dirname $0`/microservices/p/p.conf
sed "s/keystone/$KEYSTONE/" `dirname $0`/microservices/w1/w1.conf

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
    docker run -it -d -p 8080:8080 $ENVOPT -v /var/run/docker.sock:/var/run/docker.sock --name visualizer  manomarks/visualizer
fi

# Build images if not done yet
for a in web i b p s w w1 w2 db; do
	img=`docker images | grep -E "^cloudnativeapp_$a "`
	if [ _"$img" = _"" ]; then
		docker-compose build
	fi
done

# Push images in Registry if not done yet
for a in web i b p s w w1 w2 db; do
	img=`docker images | grep -E "^$REGISTRY/cloudnativeapp_$a "`
	if [ _"$img" = _"" ]; then
		docker tag cloudnativeapp_$a $REGISTRY/cloudnativeapp_$a
		docker push $REGISTRY/cloudnativeapp_$a
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
#		docker service create --name $a --network cnalan $OPT $REGISTRY/cloudnativeapp_$a
#	fi
#done

docker stack deploy -c docker-compose-v3.yml cna
sleep 5
docker service ls
