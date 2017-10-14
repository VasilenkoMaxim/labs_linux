#!/bin/bash

#Пути к конфигурационными и временным файлам и их названия
PATHTMP0=~/.tmp/
PATHTMP1=~/.tmp/control_processes/
FTMP0=tmp0.txt
FTMP1=tmp1.txt
#Некоторые константы
TEGGREP=#control_processes
COMMAND=control_processes.sh #певое слово выполняемой команды, нужно для корректного разделения записи кронтаба на слова

function UpdateCrontab(){ #$PATHTMP1 $FTMP0 $FTMP1
	cat $1$2 $1$3 | crontab
}

function CheckDir(){
	if ! [ -d $1 ]
	then
		mkdir $1
	fi
}
function DeleteFewTask(){ # $STR_INT $PATHTMP1 $? $COMMAND $TEGGREP $FTMP1
#	BEFOREsortirovka="$1"
#	sortirovka $2
#	for i in $AFTERsortirovka
	for i in $1
	do
		MINUTE[$i]=
	done
	j=0
	i=1
	while [[ $i -le $N ]]
	do
		if [[ -n ${MINUTE[$i]} ]]
		then
			let 'j=j+1'
			MINUTE[$j]=${MINUTE[$i]}
			HOUR[$j]=${HOUR[$i]}
			DAY[$j]=${DAY[$i]}
			MONTH[$j]=${MONTH[$i]}
			WEEKDAY[$j]=${WEEKDAY[$i]}
			ARG[$j]=${ARG[$i]}
			STR[$j]=`echo ${MINUTE[$j]}" "${HOUR[$j]}" "${DAY[$j]}" "${MONTH[$j]}" "${WEEKDAY[$j]}" "$4" "${ARG[$j]}" "$5 | sed "s/@/*/g"`
		fi
		let 'i=i+1'
	done
	N=$j
	rm $2$6
	if [[ $N != 0 ]]
	then
		i=1
		while [[ $i -le $N ]]
		do
			echo "${STR[$i]}" >> $2$6
			let 'i=i+1'
		done
	fi
}

function DeleteTaskDialog(){ #$PATHTMP1 $PATHCONFIG $COMMAND $TEGGREP $FTMP1
	PrintCrontabTask
	echo "Введи номера удаляемых заданий через пробел"
	read strDeleteTaskDialog
	DeleteFewTask "$strDeleteTaskDialog" $1 $2 $3 $4 $5
}

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
	let 'N=N-1'
	rm $1$2
	cd $1 && rename "s/"$2".tmp""/"$2"/" $2".tmp"
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

function EditTaskDialog(){ # $COMMAND $TEGGREP $PATHTMP1 $FTMP1
	PrintCrontabTask
	echo "Введите номер задания которое нужно отредактировать, при редактировании, пустая строка не изменит параметр"
	read k
	PrintCrontabTask $k
	echo "Введи название программы, выполнение которой необходимо контролировать"
	STR=${ARG[$k]}
	read ARG[$k]
	if [[ -z ${ARG[$k]} ]]
	then
		ARG[$k]=$STR
	fi
	echo "Введи время часы, минуты, дни, месяцы, день недели (1-понедельник, 7-воскресенье)"
	echo "(запись типа @/10 задаст периодичность, кроме дня недели)"
	echo "Час"
	read TMP 
	if [[ -n $TMP ]]
	then
		HOUR[$k]=$TMP
	fi
	echo "Минуты"
	read TMP
	if [[ -n $TMP ]]
	then
		MINUTE[$k]=$TMP
	fi
	echo "День месяца"
	read TMP
	if [[ -n $TMP ]]
	then
		DAY[$k]=$TMP
	fi
	echo "Месяц"
	read TMP
	if [[ -n $TMP ]]
	then
		MONTH[$k]=$TMP
	fi 
	echo "День недели"
	read TMP
	if [[ -n $TMP ]]
	then
		WEEKDAY[$k]=$TMP
	fi
	STR=`echo ${MINUTE[$k]}" "${HOUR[$k]}" "${DAY[$k]}" "${MONTH[$k]}" "${WEEKDAY[$k]}" "$1" "${ARG[$k]}" "$2 | sed "s/@/*/g"`
	ReplaceStr $3 $4 $k "$STR"
}

function PrintCrontabTask(){
	echo "Список заданий на автоматическую проверку выполнения процессов (@/10 - означает периодичность по данной величине, например по минутам)"
	echo "@ означает кажный, т.е. каждый день, каждый месяц"" $N"
	i=1
	if [[ -n $1 ]]
	then
		echo "№"$1" Дата, время H:M, D.M.DW, имя процесса: ""${HOUR[$1]}"":""${MINUTE[$1]}"", ""${DAY[$1]}"".""${MONTH[$1]}"".""${WEEKDAY[$1]}"", ""${ARG[$1]}"
	else
		while [[ $i -le $N ]]
		do
			echo "№"$i" Дата, время H:M, D.M.DW, имя процесса: ""${HOUR[$i]}"":""${MINUTE[$i]}"", ""${DAY[$i]}"".""${MONTH[$i]}"".""${WEEKDAY[$i]}"", ""${ARG[$i]}"
			let 'i=i+1'
		done
	fi
	echo ""
}

function CreateTaskDialog(){ #$COMMAND $TEGGREP $PATHTMP1 $FTMP1 
	let 'N=N+1'
	echo "Введи название программы, выполнение которой необходимо контролировать"
	read ARG[$N]
	echo "Введи время часы, минуты, дни, месяцы, день недели (1-понедельник, 7-воскресенье)"
	echo "(запись типа @/10 задаст периодичность, кроме дня недели)"
	echo "Час"
	read HOUR[$N] 
	echo "Минуты"
	read MINUTE[$N]
	echo "День месяца"
	read DAY[$N] 
	echo "Месяц"
	read MONTH[$N] 
	echo "День недели"
	read WEEKDAY[$N]
	STR=`echo ${MINUTE[$N]}" "${HOUR[$N]}" "${DAY[$N]}" "${MONTH[$N]}" "${WEEKDAY[$N]}" "$1" "${ARG[$N]}" "$2 | sed "s/@/*/g"`
	echo "$STR" >> $3$4
}

function CreateEditDeleteTaskDialog(){
	choiceCreateEditDeleteTaskDialog=0
	while [[ $choiceCreateEditDeleteTaskDialog != 4 ]]
	do
		#Сначало выводить уже имеющиеся а потом диалог
		PrintCrontabTask
		echo "Что ты хочешь сделать:"
		echo "1) Создать"
		echo "2) Редактировать"
		echo "3) Удалить"
		echo "4) В главное меню"
		read choiceCreateEditDeleteTaskDialog	
		case $choiceCreateEditDeleteTaskDialog in
			1)
				CreateTaskDialog $COMMAND $TEGGREP $PATHTMP1 $FTMP1 $PATHCONFIG
				UpdateCrontab $PATHTMP1 $FTMP0 $FTMP1 
			;;
			2)
				EditTaskDialog $COMMAND $TEGGREP $PATHTMP1 $FTMP1 $PATHCONFIG
				UpdateCrontab $PATHTMP1 $FTMP0 $FTMP1
			;;
			3)
				DeleteTaskDialog $PATHTMP1 1 $COMMAND $TEGGREP $FTMP1
				UpdateCrontab $PATHTMP1 $FTMP0 $FTMP1	
			;;
			4)
				echo "Главное меню:"
			;;
			*)
				echo "Попробуй еще раз"
			;;
		esac
	done
	return 0
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