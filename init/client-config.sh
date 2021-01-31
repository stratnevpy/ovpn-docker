#!/bin/bash
PORT=$1

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/.const

#ASEDIR=/opt/ovpn

cd $BASEDIR
if [ ! -d client-configs ]; then mkdir client-configs; fi
if [ ! -f client-configs/base.conf ]; then
        touch client-configs/base.conf
        echo """client
dev tun
;dev-node MyTap
proto udp
remote <ipaddress> $PORT
;remote-random
resolv-retry infinite
nobind
;user nobody
;group nogroup
persist-key
persist-tun
ca ca.crt
#cert client.crt
#key client.key
remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-CBC
data-ciphers AES-256-GCM:AES-256-CBC
auth SHA256
key-direction 1
verb 3
auth-nocache
explicit-exit-notify""" > client-configs/base.conf
fi
