#!/bin/bash

iptables -F


PATHCONFIG=/home/maxim/labs_linux/lab7/rulesmyfw.txt
PATHNETWORKSCRIPT=/etc/network/if-up.d/rulesmyfw
APLTG=#application
PROTTG=#protocol
PORTTG=#port

i=2
APL=(`sed -n "$i""p" $PATHCONFIG`)
let 'i=i+2'
PROT=(`sed -n "$i""p" $PATHCONFIG`)
let 'i=i+2'
PORT=(`sed -n "$i""p" $PATHCONFIG`)
while [[ -n ${APL[0]} ]]
do
	j=0
	check=0
	while [[ -n ${APL[$j]} ]]; do
		STR=`which ${APL[$j]}`
		if [[ -n $STR ]]
		then
			check=1
		fi	
		let 'j=j+1'
	done
	
	if [[ $check == 1 ]]
	then
		j=0
		while [[ -n ${PROT[$j]} ]]
		do
			if  [[ ${PROT[$j]} == tcp ]]
			then
				iptables -t filter -A INPUT -p tcp -m tcp --dport $PORT -j ACCEPT --tcp-flags SYN,FIN,RST,ACK SYN
			fi
			if  [[ ${PROT[$j]} == udp ]]
			then
				iptables -t filter -A INPUT -p udp -m udp --dport $PORT -j ACCEPT
			fi 
			let 'j=j+1'	
		done
	fi
	let 'i=i+2'
	APL=(`sed -n "$i""p" $PATHCONFIG`)
	let 'i=i+2'
	PROT=(`sed -n "$i""p" $PATHCONFIG`)
	let 'i=i+2'
	PORT=(`sed -n "$i""p" $PATHCONFIG`)
done

iptables -t filter -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT --tcp-flags SYN,FIN,RST,ACK SYN
iptables -t filter -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp -m tcp --dport 0:1024 -j DROP
iptables -t filter -A INPUT -p udp -m udp --dport 0:1024 -j DROP


touch $PATHNETWORKSCRIPT
chmod 755 $PATHNETWORKSCRIPT
echo "#!/sbin/iptables-restore" > $PATHNETWORKSCRIPT
iptables-save >> $PATHNETWORKSCRIPT
cat $PATHNETWORKSCRIPT
iptables -L

exit 0
