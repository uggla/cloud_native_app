#!/bin/bash

# Script to run the CNA as docker services on swarm

#
# You need to provide your Registry address here:
#REGISTRY=uggla
#REGISTRY=lab7-2.labossi.hpintelco.org:5500
#KEYSTONE=labossi.hpintelco.org
#WEB=`hostname`
#svc=`docker service ls | grep -E " rabbit "`
#if [ _"$svc" != _"" ]; then
#	docker service rm rabbit
#fi
#
#svc=`docker service ls | grep -E " redis "`
#if [ _"$svc" != _"" ]; then
#	docker service rm redis
#fi
#
## Launch services - Should be replaced by docker-compose v3 once available
#for a in web i b p s w w1 w2 db; do
#	svc=`docker service ls | grep -E " $a "`
#	if [ _"$svc" != _"" ]; then
#		docker service rm $a
#	fi
#done
#
#
## Check if the overlay network is available
#docker network list | grep -E " cnalan " > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    docker network rm cnalan
#fi

docker stack rm cna
sleep 5
docker service ls
