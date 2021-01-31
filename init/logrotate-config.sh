#!/bin/bash
VPN=$1

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
source $SCRIPTPATH/.const

#BASEDIR=/opt/ovpn
echo "$BASEDIR/logs/$VPN.log {
  rotate 30
  daily
  copytruncate
  compress
  missingok
  notifempty
  create 0640 root root
}" > /etc/logrotate.d/openvpn@$VPN

