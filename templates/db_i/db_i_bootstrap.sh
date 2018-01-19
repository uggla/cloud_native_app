#!/bin/bash -xe

echo -e "127.0.1.1\t$(hostname)" >> /etc/hosts

apt-get -y update
apt-get -y install docker.io

systemctl enable docker
systemctl start docker

mkdir /dockerbuild

cd /dockerbuild

#Fetch files db

wget ftp://185.212.225.4/hp/db/Dockerfile
wget ftp://185.212.225.4/hp/db/dump/prestashop_fullcustomer.dump.sql

mkdir dump
mv prestashop_fullcustomer.dump.sql dump

docker build -t db .

docker run -d --network=host --expose=3306 -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" -e MYSQL_DATABASE="$MYSQL_DATABASE" -e MYSQL_USER="$MYSQL_USER" -e MYSQL_PASSWORD="$MYSQL_PASSWORD" db

cd /

rm -rf /dockerbuild

docker pull gonnachg/service_i
docker run -d --network=host --expose=8080 gonnachg/service_i
