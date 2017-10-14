#!/bin/bash

#echo "akflj 10.30/40*130 lasjal" > ./test.txt
#sed -n 1p ./test.txt | sed "s/[]/ /g"
#"s/[\.\/\*]*/ /g"


		      #    1     2   3    4   5   6   7   8
function chek_date(){ # YEAR MONTH DAY HOUR MIN SEC NVY CVY
	if [[ $7 != 0 && $2 == 2 && $3 == 29 ]]
	then
		echo "Ошибка: 29 февраля есть только в високосном году"
	fi
	
}


function read_dates(){
	while [[ $YEAR != "exit" ]]
	do
		echo "Введите дату с которой будет осуществляться поиск логов: YEAR MONTH DAY HOUR MIN SEC, для выхода введите: exit"
		echo "Нужно вводить целые числа в виде: 3 или 03"
		read YEAR MONTH DAY HOUR MIN SEC
		let 'NVY=YEAR/4'
		let 'CVY=YEAR%4'
	done
}

A=10
B=01
let 'B=B'
echo $B