#!/bin/bash
USERNAME=$1
VPN=$2
docker exec $VPN bin/revoke_user.sh $USERNAME $VPN 
