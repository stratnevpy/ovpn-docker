#!/bin/bash
#OCKFILE=.gen
#VPN=uriit
VPN=$1
PORT=$2
NET=$3
MASK=$4

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/.const

#BASEDIR=/opt/ovpn
#VPNDIR=/etc/openvpn
EASYRSADIR=$BASEDIR/easy-rsa

if [ ! -d $EASYRSADIR ]; then 
	mkdir $EASYRSADIR
	cp -r /tmp/Easy*/* $EASYRSADIR
fi

cd $BASEDIR
if [ ! -f $LOCKFILE ]; then
	$EASYRSADIR/easyrsa init-pki
	EASYRSA_REQ_CN=$VPN-ca $EASYRSADIR/easyrsa --batch build-ca nopass
	EASYRSA_REQ_CN=$VPN.server $EASYRSADIR/easyrsa --batch gen-req $VPN.server nopass
	EASYRSA_CERT_EXPIRE=3650 $EASYRSADIR/easyrsa --batch sign-req server $VPN.server
	$EASYRSADIR/easyrsa gen-dh
	openvpn --genkey secret ta.key
	touch $LOCKFILE
fi

if [ ! -L $BASEDIR/easy-rsa/pki ]; then ln -s $BASEDIR/pki $BASEDIR/easy-rsa/pki; fi
if [ ! -L $VPNDIR/ca.crt ]; then ln -s $BASEDIR/pki/ca.crt $VPNDIR/ca.crt; fi
if [ ! -L $VPNDIR/$VPN.server.crt ]; then ln -s $BASEDIR/pki/issued/$VPN.server.crt $VPNDIR/$VPN.server.crt; fi
if [ ! -L $VPNDIR/$VPN.server.key ]; then ln -s $BASEDIR/pki/private/$VPN.server.key $VPNDIR/$VPN.server.key; fi
if [ ! -L $VPNDIR/dh.pem ]; then ln -s $BASEDIR/pki/dh.pem $VPNDIR/dh.pem; fi
if [ ! -L $VPNDIR/ta.key ]; then ln -s $BASEDIR/ta.key $VPNDIR/ta.key; fi
