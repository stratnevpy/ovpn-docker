#!/bin/bash
USERNAME=$1
VPN=$2
BASEDIR=/opt/ovpn
VPNDIR=/etc/openvpn
EASYRSADIR=$BASEDIR/easy-rsa

users=($(echo $USERNAME | tr ',' "\n"))
cd $EASYRSADIR
for user in ${users[@]}
do
        client_config=$BASEDIR/client-configs/$user
        perm_file=$BASEDIR/permissions/$VPN.$user
        ccd_file=$BASEDIR/ccd/$VPN.$user
        ./easyrsa --batch revoke $VPN.$user
        if [ -d $client_config ]; then rm -rf $client_config; fi
        if [ -f $perm_file ]; then rm -f $perm_file; fi
        if [ -f $ccd_file ]; then rm -f $ccd_file; fi
done
$VPNDIR/bin/update_crl.sh