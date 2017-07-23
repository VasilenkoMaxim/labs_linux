#!/bin/bash


SUBSTITUTE_STR="*/1 */20 */7 * * aaa /asd/asd/dca #assfa"

function ReplaceStr(){   # $PATH_DIR_FILE $NAME_FILE $NUMBER_STR "$SUBSTITUTE_STR"
	N=1
	READ_STR=`sed -n "$N"p $1$2`
	while [[ -n $READ_STR ]]
	do
		if [[ $N == $3 ]]
		then
			echo "$4" >> $1$2".tmp"
		else
			echo "$READ_STR" >> $1$2".tmp"
		fi
		let 'N=N+1'
		READ_STR=`sed -n "$N"p $1$2`
	done
	rm $1$2
	cd $1 && rename "s/"$2".tmp""/"$2"/" $2".tmp"
}
#ReplaceStr $1 $2 $3 "$SUBSTITUTE_STR"
#cat $1$2\
STR="/10"

if [[ -n `echo $STR | grep /` ]]
then
	STR="*"$STR
	echo "$STR"
fi

STR="* */20"
a=($STR)
echo "${a[0]}"
echo "${a[1]}"

PATHTMP1=~/.tmp/mybackup/
#$BEFOREsortirovka-строка состоящая из чисел (слов) через пробелы
#$AFTERsortirovka-строка с отсортированными числами
function sortirovka(){ #$PATHTMP
	a=($BEFOREsortirovka)
	echo ${a[0]} > $1"sort0.tmp"
	i=1
	while [[ -n ${a[i]} ]] 
	do
		echo ${a[$i]} >> $1"sort0.tmp"
		let 'i=i+1'
	done
	cat $1"sort0.tmp" | sort -V > $1"sort1.tmp" 
	j=2
	AFTERsortirovka=`sed -n "1p" $1"sort1.tmp"`
	while [[ $j -le $i ]]
	do
		a=`sed -n "$j""p" $1"sort1.tmp"`
		AFTERsortirovka=$AFTERsortirovka" "$a
		let 'j=j+1'
	done
	rm $1"sort0.tmp" $1"sort1.tmp"
}


BEFOREsortirovka="19 32 31 10 11 4 1 0 5 73 101"
sortirovka $PATHTMP1
echo $AFTERsortirovka
S=`ls $PATHTMP1`
echo $S

PATHCONFIG=~/.config/mybackup/
function RefreshConfigFile(){ # $PATHCONFIG
	STR=`ls $1`
	a=($STR)
	i=0
	while [[ -n ${a[i]} ]]
	do
		let 'j=i+1'
		cd $1 && rename "s/""${a[i]}""/""$j"".cfg""/" "${a[i]}"
		let 'i=i+1'
	done
}

RefreshConfigFile $PATHCONFIG