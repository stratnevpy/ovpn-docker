#!/bin/bash
USERNAME=$1
VPN=$2
if [ -z $3 ]; then
        EXPIRE=365
else
        EXPIRE=$3
fi
BASEDIR=/opt/ovpn
EASYRSA_DIR=$BASEDIR/easy-rsa
VPN_DIR=/etc/openvpn

users=($(echo $USERNAME | tr ',' "\n"))

cd $EASYRSA_DIR
for user in ${users[@]}
do
        if [ -f $BASEDIR/pki/private/$VPN.$user.key ]; then $VPN_DIR/bin/revoke_user.sh $VPN.$user; fi
        
	EASYRSA_REQ_CN=$VPN.$user ./easyrsa --batch gen-req $VPN.$user nopass
        EASYRSA_CERT_EXPIRE=$EXPIRE $EASYRSA_DIR/easyrsa --batch sign-req client $VPN.$user
        
	if [ ! -d $BASEDIR/client-configs/$user ]; then mkdir $BASEDIR/client-configs/$user; fi
	if [ ! -L $BASEDIR/client-configs/$user/$user.key ]; then ln -s $BASEDIR/pki/private/$VPN.$user.key $BASEDIR/client-configs/$user/$user.key; fi
	if [ ! -L $BASEDIR/client-configs/$user/$user.crt ]; then ln -s $BASEDIR/pki/issued/$VPN.$user.crt $BASEDIR/client-configs/$user/$user.crt; fi
        if [ ! -L $BASEDIR/client-configs/$user/ca.crt ]; then ln -s $BASEDIR/pki/ca.crt $BASEDIR/client-configs/$user/ca.crt; fi
        if [ ! -L $BASEDIR/client-configs/$user/ta.key ]; then ln -s $BASEDIR/ta.key $BASEDIR/client-configs/$user/ta.key; fi
       	if [ ! -f $BASEDIR/ccd/$VPN.$user ]; then touch $BASEDIR/ccd/$VPN.$user; fi
	#if [ ! -L $VPN_DIR/ccd/$VPN.$user ]; then ln -s $BASEDIR/ccd/$VPN.$user $VPN_DIR/ccd/$VPN.$user; fi
	if [ ! -f $BASEDIR/permissions/$VPN.$user ]; then touch $BASEDIR/permissions/$VPN.$user; fi
        #if [ ! -L $VPN_DIR/permissions/$VPN.$user ]; then ln -s $BASEDIR/permissions/$VPN.$user $VPN_DIR/permissions/$VPN.$user; fi      
	cp $BASEDIR/client-configs/base.conf $BASEDIR/client-configs/$user/$user.ovpn
        sed -i "s/#cert client.crt/cert $user.crt/g" $BASEDIR/client-configs/$user/$user.ovpn
        sed -i "s/#key client.key/key $user.key/g" $BASEDIR/client-configs/$user/$user.ovpn
	cd $BASEDIR/client-configs
	tar -chf $user/$user.tar $user/*
done
