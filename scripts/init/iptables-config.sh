#!/bin/bash
NET=$1
MASK=$2
BASEDIR=/opt/ovpn
IPTABLESCONFIG=$BASEDIR/iptables.rules

if [ ! -f $IPTABLESCONFIG ]; then
	touch $IPTABLESCONFIG
	echo """*filter
:INPUT DROP 
:FORWARD DROP
:OUTPUT DROP
-A INPUT -i eth0 -p udp -m state --state NEW,ESTABLISHED -m udp --dport 1194 -j ACCEPT
-A INPUT -i tun0 -j ACCEPT
-A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -o eth0 -p udp -m state --state ESTABLISHED -m udp --sport 1194 -j ACCEPT
-A OUTPUT -o tun0 -j ACCEPT
COMMIT

*nat
:PREROUTING ACCEPT
:INPUT ACCEPT
:POSTROUTING ACCEPT
:OUTPUT ACCEPT
-A POSTROUTING -s $NET/$MASK -o eth0 -j SNAT --to-source $(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
COMMIT""" >> $IPTABLESCONFIG
fi
iptables-legacy-restore < $IPTABLESCONFIG
