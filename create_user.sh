#!/bin/bash
USERNAME=$1
VPN=$2
EXPIRE=$3
if [ -z $3 ]; then
	EXPIRE=365
else
	EXPIRE=$3
fi

docker exec -it $VPN bin/make_user.sh $USERNAME $VPN $EXPIRE

