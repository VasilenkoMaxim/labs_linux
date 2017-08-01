#!/bin/bash

function FourToOne(){ # $1 $2 $3 $4
	A[0]=$1
	A[1]=$2
	A[2]=$3
	A[3]=$4
	CHECK=
	B=0
	for i in 3 2 1 0
	do
		for j in 0 1 2 3 4 5 6 7
		do
			let 'CHECK=A[$i]&1'
			let 'B>>=1'
			if [[ $CHECK == 1 ]]
			then
				let 'B=B+2147483648'
			fi
			let 'A[$i]>>=1'
		done
	done
}

function PrintBitsFromInt(){ # $(десятичное число типа int) $dot $space
	C=$1
	CHECK=
	STR=
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 
	do
		let 'CHECK=C&1'
		let 'j=32-i'
		if [[ $3 == $j ]]
		then
			STR=" "$STR
		fi
		if [[ $2 == 1 && ( $i == 8 || $i == 16 || $i == 24 ) ]]
		then
			STR="."$STR
		fi
	    if [[ $CHECK == 1 ]]
	    then
	        STR="1"$STR
	    else
	        STR="0"$STR
	    fi
	    let 'C>>=1'
	done
	printf "$STR"
}

function GetMask(){ # $1
	CHECK=$1
	B=0
	while [[ $CHECK != 0 ]]
	do
		let 'B>>=1'
		let 'B=B+2147483648'
		let 'CHECK=CHECK-1'
	done
}

function PrintBitsFromInt(){ # $(десятичное число типа int) $dot $space
	C=$1
	CHECK=
	STR=
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 
	do
		let 'CHECK=C&1'
		let 'j=32-i'
		if [[ $3 == $j ]]
		then
			STR=" "$STR
		fi
		if [[ $2 == 1 && ( $i == 8 || $i == 16 || $i == 24 ) ]]
		then
			STR="."$STR
		fi
	    if [[ $CHECK == 1 ]]
	    then
	        STR="1"$STR
	    else
	        STR="0"$STR
	    fi
	    let 'C>>=1'
	done
	printf "$STR"
}

function OneToFour(){ # $1
	B=$1
	CHECK=
	for i in 3 2 1 0
	do
		A[$i]=0;
		for j in 0 1 2 3 4 5 6 7
		do
			let 'CHECK=B&1'
			if [[ $CHECK == 1 ]]
			then
				let 'A[$i]=A[$i]+2**j'
			fi
			let 'B>>=1'
		done
	done
}

STR=`echo $1 | sed "s/[\.\/]/ /g"`
A=($STR)
NMASK=${A[4]}
IPmas[0]=${A[0]}
IPmas[1]=${A[1]}
IPmas[2]=${A[2]}
IPmas[3]=${A[3]}
FourToOne ${A[0]} ${A[1]} ${A[2]} ${A[3]}
IP=$B
GetMask ${A[4]}
MASK=$B

OneToFour $MASK
MASKmas[0]=${A[0]}
MASKmas[1]=${A[1]}
MASKmas[2]=${A[2]}
MASKmas[3]=${A[3]}
let 'WC=MASK^(256*256*256*256-1)' #Wildcard
OneToFour $WC
WCmas[0]=${A[0]}
WCmas[1]=${A[1]}
WCmas[2]=${A[2]}
WCmas[3]=${A[3]}
let 'NW=MASK&IP' #Network
OneToFour $NW
NWmas[0]=${A[0]}
NWmas[1]=${A[1]}
NWmas[2]=${A[2]}
NWmas[3]=${A[3]}
let 'HMin=NW+1' #HostMin
OneToFour $HMin
HMinmas[0]=${A[0]}
HMinmas[1]=${A[1]}
HMinmas[2]=${A[2]}
HMinmas[3]=${A[3]}
let 'HMax=NW+WC-1' #HostMax
OneToFour $HMax
HMaxmas[0]=${A[0]}
HMaxmas[1]=${A[1]}
HMaxmas[2]=${A[2]}
HMaxmas[3]=${A[3]}
let 'BC=NW+WC' #Broadcast
OneToFour $BC
BCmas[0]=${A[0]}
BCmas[1]=${A[1]}
BCmas[2]=${A[2]}
BCmas[3]=${A[3]}
let 'HOSTS=HMax-HMin+1';

#tput setaf $цифра - установка цвета печати сообщения
#tput sgr0 - сброс на стандартный цвет

printf "%-11s" "Address:"; printf "%-21s" "${IPmas[0]}.${IPmas[1]}.${IPmas[2]}.${IPmas[3]}"; PrintBitsFromInt $IP 1 ${A[4]}; printf "\n"
printf "%-11s" "Netmask:"; printf "%-21s" "${MASKmas[0]}.${MASKmas[1]}.${MASKmas[2]}.${MASKmas[3]} = $NMASK"; PrintBitsFromInt $MASK 1 ${A[4]}; printf "\n"
printf "%-11s" "Wildcard:"; printf "%-21s" "${WCmas[0]}.${WCmas[1]}.${WCmas[2]}.${WCmas[3]}"; PrintBitsFromInt $WC 1 ${A[4]}; printf "\n"
echo "=>"
printf "%-11s" "Network:"; printf "%-21s" "${NWmas[0]}.${NWmas[1]}.${NWmas[2]}.${NWmas[3]}/$NMASK"; PrintBitsFromInt $NW 1 ${A[4]}; printf "\n"
printf "%-11s" "HostMin:"; printf "%-21s" "${HMinmas[0]}.${HMinmas[1]}.${HMinmas[2]}.${HMinmas[3]}"; PrintBitsFromInt $HMin 1 ${A[4]}; printf "\n"
printf "%-11s" "HostMax:"; printf "%-21s" "${HMaxmas[0]}.${HMaxmas[1]}.${HMaxmas[2]}.${HMaxmas[3]}"; PrintBitsFromInt $HMax 1 ${A[4]}; printf "\n"
printf "%-11s" "Broadcast:"; printf "%-21s" "${BCmas[0]}.${BCmas[1]}.${BCmas[2]}.${BCmas[3]}"; PrintBitsFromInt $BC 1 ${A[4]}; printf "\n"
printf "%-11s" "Hosts/Net"; printf "%-21s" "$HOSTS"; printf "\n"


exit 0