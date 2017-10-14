#!/bin/bash
S=(`ip addr show wlan0 | grep "inet " | sed "s/\// /g"`)
MY_IP="${S[1]}VM"
#echo $MY_IP
TARGET_IP="192.168.101.248"
#TARGET_IP="192.168.1.101"
TARGET_PATH="/home/nfs/"
#TARGET_PATH="/home/maxim/nfs/"
MY_PATH="/media/nfs"
TEG="#VasilenkoMaxim"
t=`date '+%d.%m.%y %H:%M:%S'`;
#echo $t



case $1 in
	1)
#		echo "start"
		mount -t nfs $TARGET_IP:$TARGET_PATH $MY_PATH
		if [[ !(-f $MY_PATH/$MY_IP) ]]
		then
			touch $MY_PATH/$MY_IP
			chmod 666 $MY_PATH/$MY_IP
		fi
		echo "$t Start $USER $TEG" >> $MY_PATH/$MY_IP
	;;
	2)
#		echo "stop"
		if [[ !(-f $MY_PATH/$MY_IP) ]]
		then
			touch $MY_PATH/$MY_IP
			chmod 666 $MY_PATH/$MY_IP
		fi
		echo "$t Stop $USER $TEG" >> $MY_PATH/$MY_IP
		umount -l  $MY_PATH
	;;
	3)
#		echo "login"
#		mount -t nfs $TARGET_IP:$TARGET_PATH $MY_PATH
		if [[ -f $MY_PATH/$MY_IP ]]
		then
			echo "$t Login $USER $TEG" >> $MY_PATH/$MY_IP
		fi
#		umount -l  $MY_PATH
	;;
	4)
		echo "logout"
	;;
	*)
		exit 1;
	;;
esac