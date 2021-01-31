#!/bin/bash
#VPN=uriit
VPN=$1
PORT=$2
NET=$3
MASK=$4
#WORKDIR=/opt/ovpn
DOCKER=~/docker

#rm -rf $WORKDIR/$VPN
#mkdir $WORKDIR/$VPN
cd $DOCKER
docker build -t ovpn .
docker run -d --name $VPN --restart unless-stopped --cap-add=NET_ADMIN -v /opt/ovpn/$VPN:/opt/ovpn -v /etc/localtime:/etc/localtime:ro -p $PORT:1194/udp ovpn $VPN $PORT $NET $MASK
cd -
