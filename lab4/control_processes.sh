#!/bin/bash

#Пути к конфигурационными и временным файлам и их названия
PATHTMP0=~/.tmp/
PATHTMP1=~/.tmp/control_rpocesses/
FTMP0=tmp0.txt
FTMP1=tmp1.txt
#Некоторые константы
TEGGREP=#control_rpocesses
COMMAND=control_rpocesses.sh #певое слово выполняемой команды, нужно для корректного разделения записи кронтаба на слова

function CheckDir(){
	if ! [ -d $1 ]
	then
		mkdir $1
	fi
}

function CarryOut(){ # $Имя_процесса $Дополнительные параметры
	CHECK_PID=`pidof $1`;
	#echo ${#CHECK_PID}
	if [[ -z $CHECK_PID ]]
	then
		if [[ -n $2 ]]
		then
			$1 &
		else
			$1
		fi
	else
		echo "Процесс с данным именем уже запущен"
	fi
}

function ReadCrontab(){ # $TEGGREP $PATHTMP $NAME_FILE_WITHOUT_TEG $NAME_FILE_WITH_TEG
	crontab -l | grep -v $1 > $2$3
	crontab -l | grep $1 > $2$4
}
#Читает записи по строчкам и раскладывает данные по переменным, полностью актульно только для mybackup
#COMMAND - первое слово команды в записи кронтаба, идущее сразу после временных параметров
#MINUTE
#HOUR
#DAY
#MONTH
#WEEKDAY
#ARG
#N - количество записей в crontab
#STR - временная строка для чтения из файла по словам
function ReadCrontabStr(){ # $PATH_TO_FILE
	N=1
	STR=`sed -n "$N""p" "$1" | sed "s/*/@/g"`
	while [[ -n $STR ]]
	do
		A=($STR)
		MINUTE[$N]="${A[0]}"
		HOUR[$N]="${A[1]}"
		DAY[$N]="${A[2]}"
		MONTH[$N]="${A[3]}"
		WEEKDAY[$N]="${A[4]}"
		ARG[$N]="${A[6]}"
		let 'N=N+1'
		STR=`sed -n "$N""p" "$1" | sed "s/*/@/g"`
	done
	let 'N=N-1'
}

function PrintCrontabTask(){
	echo "Список заданий на автоматическую проверку выполнения процессов (@/10 - означает периодичность по данной величине, например по минутам)"
	echo "@ означает кажный, т.е. каждый день, каждый месяц"" $N"
	i=1
	if [[ -n $1 ]]
	then
		echo "№"$1" Дата, время H:M, D.M.DW, имя процесса: ""${HOUR[$1]}"":""${MINUTE[$1]}"" ""${DAY[$1]}"".""${MONTH[$1]}"".""${WEEKDAY[$1]}""${ARG[$1]}"
	else
		while [[ $i -le $N ]]
		do
			echo "№"$i" Дата, время H:M, D.M.DW, имя процесса: ""${HOUR[$i]}"":""${MINUTE[$i]}"" ""${DAY[$i]}"".""${MONTH[$i]}"".""${WEEKDAY[$i]}""${ARG[$i]}"
			let 'i=i+1'
		done
	fi
}

function MainDialog(){
	choiceMainDialog=0
	echo "Привет чувак, я скрипт control_rpocesses, что мне сделать:"
	while [[ $choiceMainDialog != 4 ]]
	do
		ReadCrontab $TEGGREP $PATHTMP1 $FTMP0 $FTMP1
		ReadCrontabStr $PATHTMP1$FTMP1
		echo "1) Проверить процесс прям сейчас"
		echo "2) Создать, редактировать, удалить задание на автоматическую проверку выполнения процессов"
		echo "3) Показать уже имеющиеся задания на автоматическую проверку выполнения процесса"
		echo "4) Ты зашел сюда случайно и хочешь выйти((("
		echo "PS Введи цифру и нажми Enter"
		read choiceMainDialog
		case $choiceMainDialog in
			1)
				echo "Введи имя процесса"
				read NAME_PROCESS
				silence=1
				CarryOut $NAME_PROCESS $silence	
			;;
			2)
				CreateEditDeleteTaskDialog
			;;
			3)
				PrintCrontabTask
			;;
			4)

			;;
			*)
			echo "Чувааак, ты ошибся с вводом, попробуй еще раз"		
		esac
	done
}



CheckDir $PATHTMP0
CheckDir $PATHTMP1

if [[ -n $1 ]]
then
	CarryOut $1
else
	MainDialog
fi

exit 0