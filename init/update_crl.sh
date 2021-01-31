#!/bin/bash
BASEDIR=/opt/ovpn
VPNDIR=/etc/openvpn
EASYRSADIR=$BASEDIR/easy-rsa

$EASYRSADIR/easyrsa gen-crl
chmod 644 $BASEDIR/pki/crl.pem
#cp $BASEDIR/pki/crl.pem $VPNDIR/crl.pem
if [ ! -L $VPNDIR/crl.pem ]; then ln -s $BASEDIR/pki/crl.pem $VPNDIR/crl.pem; fi
