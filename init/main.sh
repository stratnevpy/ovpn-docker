#!/bin/bash
VPN=$1
PORT=$2
NET=$3
MASK=$4

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/.const

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi

init/pki-config.sh $VPN $PORT $NET $MASK
init/server-config.sh $VPN $NET $MASK
init/client-config.sh $PORT
init/iptables-config.sh $NET $MASK
init/logrotate-config.sh $VPN

openvpn --config $VPNDIR/server.conf
