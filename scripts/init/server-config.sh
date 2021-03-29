#!/bin/bash
VPN=$1
NET=$2
MASK=$3
BASEDIR=/opt/ovpn
VPNDIR=/etc/openvpn

cd $BASEDIR
if [ ! -d logs ]; then mkdir logs; fi
if [ ! -L $VPNDIR/logs ]; then ln -s $BASEDIR/logs $VPNDIR/logs; fi
if [ ! -d ccd ]; then mkdir ccd; fi
if [ ! -L $VPNDIR/ccd ]; then ln -s $BASEDIR/ccd $VPNDIR/ccd; fi
if [ ! -d permissions ]; then
        mkdir permissions
        touch permissions/default
fi
if [ ! -L $VPNDIR/permissions ]; then ln -s $BASEDIR/permissions $VPNDIR/permissions; fi

if [ ! -f $BASEDIR/server.conf ]; then
	touch $BASEDIR/server.conf
	echo """port 1194
proto udp
dev tun
ca $VPNDIR/ca.crt
cert $VPNDIR/$VPN.server.crt
key $VPNDIR/$VPN.server.key
dh $VPNDIR/dh.pem
topology subnet
server $NET $MASK
ifconfig-pool-persist $VPNDIR/logs/ipp.txt
;push "redirect-gateway def1 bypass-dhcp"
;push "dhcp-option DNS 208.67.222.222"
client-to-client
client-config-dir $VPNDIR/ccd
;duplicate-cn
keepalive 10 120
cipher AES-256-CBC
data-ciphers AES-256-GCM:AES-256-CBC
auth SHA256
user root
group root
persist-key
persist-tun
status $VPNDIR/logs/$VPN-status.log
log-append $VPNDIR/logs/$VPN.log
verb 5
tls-server
tls-version-min 1.2
tls-auth $VPNDIR/ta.key 0
explicit-exit-notify 1
reneg-sec 0
script-security 2
crl-verify $VPNDIR/crl.pem
client-connect $VPNDIR/bin/permissions.rb
client-disconnect $VPNDIR/bin/permissions.rb
""" >> $BASEDIR/server.conf
fi
if [ ! -L $VPNDIR/server.conf ]; then ln -s $BASEDIR/server.conf $VPNDIR/server.conf; fi
$VPNDIR/bin/update_crl.sh
if [ ! -L /etc/cron.daily/crl ]; then ln -s $VPNDIR/bin/update_crl.sh /etc/cron.daily/crl; fi
