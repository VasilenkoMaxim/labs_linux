#!/bin/bash
S=(`ip addr show wlan0 | grep "inet " | sed "s/\// /g"`)
MY_IP=${S[1]}
TARGET_IP="192.168.101.248"
TARGET_PATH="/media/nfs/"

case $1 in
	1)
		echo "start"
	;;
	2)
		echo "stop"
	;;
	3)
		echo "login"
	;;
	4)
		echo "logout"
	;;
	*)
		exit 1;
	;;
esac