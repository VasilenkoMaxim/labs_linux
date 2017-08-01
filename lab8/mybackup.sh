#!/bin/bash

#Пути к конфигурационными и временным файлам и их названия
PATHCONFIG=~/.config/mybackup/
PATHTMP0=~/.tmp/
PATHTMP1=~/.tmp/mybackup/
FTMP0=tmp0.txt
FTMP1=tmp1.txt
FCONFIG=.cfg #только конец файла, перед ним будет идти число
#Некоторые константы
TEGGREP=#mybackup
COMMAND=mybackup.sh #певое слово выполняемой команды, нужно для корректного разделения записи кронтаба на слова

#Стандартные переменные
#НЕ МАССИВЫ
#PATHfrom0
#PATHto0
#NAME0
#ARCH0 - ответ на то, нужна ли архивация, содержит y или n, или пусто
#МАСИВЫ
#PATHfrom
#PATHto
#NAME
#ARCH
#MINUTE
#HOUR
#DAY
#MONTH
#DAYWEEK
#ARG - аргумент скрипта, для скрипта mybackup это имя конфиг. файла например 1.cfg
#N - количество считаных записей по тегу

function UpdateCrontab(){ #$PATHTMP1 $FTMP0 $FTMP1
	cat $1$2 $1$3 | crontab
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
	rm $1$2
	cd $1 && rename "s/"$2".tmp""/"$2"/" $2".tmp"
}
#$BEFOREsortirovka-строка состоящая из целых чисел через пробелы
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
#Обновление содержания папки PATHCONFIG поле удаления некоторых файлов
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
#Функция для проверки наличия директориии и в случае ее отсуствия ее создание
function CheckDir(){
	if ! [ -d $1 ]
	then
		mkdir $1
	fi
}
#Функция выполняющая действие при наличии аргумента у скрипта
function CarryOut(){ # $NAME_FILE.cfg $Дополнительные параметры
	source $PATHCONFIG$1
	if [[ -b $PATHfrom0 ]]
	then
		sudo dd if=$PATHfrom0 of=$PATHto0$NAME0".iso" $2 $3 $4
 	elif [[ $ARCH0 == y ]]
 	then
 		cd $PATHfrom0 && tar -czf $PATHto0$NAME0".tgz" * $2 $3 $4
 	elif [[ $ARCH0 == n ]]
 	then
 		cd $PATHfrom0 && rsync -zr * $PATHto0$NAME0"/" $2 $3 $4
	fi
	exit 0
}
#Читает запись из контаба и записывает их во временные файлы не помеченные указаннм тегом и помеченные
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

#$1-строка с номерами удаляемых задач
function DeleteFewTask(){ # $STR_INT $PATHTMP1 $PATHCONFIG $COMMAND $TEGGREP $FTMP1
#	BEFOREsortirovka="$1"
#	sortirovka $2
#	for i in $AFTERsortirovka
	for i in $1
	do
		MINUTE[$i]=
		rm $3$i".cfg"
	done
	RefreshConfigFile $PATHCONFIG
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
			ARG[$j]=$j".cfg"
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
function EditTaskDialog(){ # $COMMAND $TEGGREP $PATHTMP1 $FTMP1 $PATHCONFIG
	PrintCrontabTask
	echo "Введите номер задания которое нужно отредактировать, при редактировании, пустая строка не изменит параметр"
	read k
	PrintCrontabTask $k
	source $1$k".cfg"
	echo "Что ты хочешь скопировать, введи новый путь директории или укажи новое блочное устройство"
	read PATHfromnew
	if [[ -z $PATHfromnew ]]
	then
		PATHfromnew=$PATHfrom0
	fi
	echo "Куда это скопировать, введи новый путь директории"
	read PATHtonew
	if [[ -z $PATHtonew ]]
	then
		PATHtonew=$PATHto0
	fi
	if [[ -b $PATHfromnew ]]
	then
		echo "Ты указал блочное устройство, введи имя ISO файла"
		read NAMEnew
		if [[ -z $NAMEnew ]]
		then
			NAMEnew=$NAME0
		fi
		ARCHnew=n
	else
		echo "Нужно ли архивирование? (y/n)"
		read ARCHnew
		if [[ -z $ARCHnew ]]
		then
			ARCHnew=$ARCH0
		fi
		if [[ $ARCHnew = "y" ]]
		then
			echo "Введи имя архива"
			read NAMEnew
			if [[ -z $NAMEnew ]]
			then
				NAMEnew=$NAME0
			fi
		else
			echo "Введи имя подпапки"
			read NAMEnew
			if [[ -z $NAMEnew ]]
			then
				NAMEnew=$NAME0
			fi
		fi
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
	STR=`echo ${MINUTE[$k]}" "${HOUR[$k]}" "${DAY[$k]}" "${MONTH[$k]}" "${WEEKDAY[$k]}" "$1" "$k".cfg"" "$2 | sed "s/@/*/g"`
	ReplaceStr $3 $4 $k "$STR"
	echo "PATHfrom0="$PATHfromnew > $5$k".cfg"
	echo "PATHto0="$PATHtonew >> $5$k".cfg"
	echo "NAME0="$NAMEnew >> $5$k".cfg"
	echo "ARCH0="$ARCHnew >> $5$k".cfg"

}

function PrintCrontabTask(){
	echo "Список заданий на резервное копирование (@/10 - означает периодичность по данной величине, например по минутам)"
	echo "@ означает кажный, т.е. каждый день, каждый месяц"
	i=1
	if [[ -n $1 ]]
	then
		source $PATHCONFIG$1$FCONFIG
		echo "Задание № "$1
		echo "Дата, время H:M, D.M.DW: ""${HOUR[$1]}"":""${MINUTE[$1]}"" ""${DAY[$1]}"".""${MONTH[$1]}"".""${WEEKDAY[$1]}"
		echo "Путь, откуда бэкапить: "$PATHfrom0
		echo "Путь, куда бэкапить: "$PATHto0
		echo "Имя файла/папки, необходимость архивации: "$NAME0", "$ARCH0
		echo
	else
		while [[ $i -le $N ]]
		do
			source $PATHCONFIG$i$FCONFIG
			echo "Задание № "$i
			echo "Дата, время H:M, D.M.DW: ""${HOUR[$i]}"":""${MINUTE[$i]}"" ""${DAY[$i]}"".""${MONTH[$i]}"".""${WEEKDAY[$i]}"
			echo "Путь, откуда бэкапить: "$PATHfrom0
			echo "Путь, куда бэкапить: "$PATHto0
			echo "Имя файла/папки, необходимость архивации: "$NAME0", "$ARCH0
			echo
			let 'i=i+1'
		done
	fi
}

function CreateBackupNowDialog(){
	echo "Что ты хочешь скопировать, введи путь директории или укажи блочное устройство"
	read PATHfromnew
	echo "Куда это скопировать, введи путь директории"
	read PATHtonew
	if [[ -b $PATHfromnew ]]
	then
		echo "Ты указал блочное устройство, введи имя ISO файла"
		read NAMEnew
		echo "Возможно придется долго ждать, дождись завершения процесса"
		echo "или нажми Ctr+c, тогда все прервется и данные могут быть повреждены"
		sudo dd if=$PATHfromnew of=$PATHtonew$NAMEnew".iso"
		if [[ $? = 0 ]]
		then
			echo "Данные успешно скопированы"
		else
			echo "Что-то пошло не так, попробуй еще раз"
		fi
	else
		echo "Нужно ли архивирование? (y/n)"
		read ARCHnew
		if [[ $ARCHnew = "y" ]]
		then
			echo "Введи имя архива"
			read NAMEnew
			cd $PATHfromnew && tar -czf $PATHtonew$NAMEnew".tgz" *
			if [[ $? = 0 ]]
			then
				echo "Данные успешно скопированы"
			else
				echo "Что-то пошло не так, попробуй еще раз"
			fi
		else
			echo "Введи имя подпапки"
			read NAMEnew
			cd $PATHfromnew && rsync -zr * $PATHtonew$NAMEnew"/"
			if [[ $? = 0 ]]
			then
				echo "Данные успешно скопированы"
			else
				echo "Что-то пошло не так, попробуй еще раз"
			fi
		fi

	fi
}

function CreateEditDeleteTaskDialog(){
	choiceCreateEditDeleteTaskDialog=0
	while [[ $choiceCreateEditDeleteTaskDialog != 4 ]]
	do
		#Сначало выводить уже имеющиеся а потом диалог
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
				DeleteTaskDialog $PATHTMP1 $PATHCONFIG $COMMAND $TEGGREP $FTMP1
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
#сделать проверку при введении пустой строки и установки тогда на @
function CreateTaskDialog(){ #$COMMAND $TEGGREP $PATHTMP1 $FTMP1 $PATHCONFIG 
	let 'N=N+1'
	echo "Что ты хочешь скопировать, введи путь директории или укажи блочное устройство"
	read PATHfromnew
	echo "Куда это скопировать, введи путь директории"
	read PATHtonew
	if [[ -b $PATHfromnew ]]
	then
		echo "Ты указал блочное устройство, введи имя ISO файла"
		read NAMEnew
		ARCHnew=n
	else
		echo "Нужно ли архивирование? (y/n)"
		read ARCHnew
		if [[ $ARCHnew = "y" ]]
		then
			echo "Введи имя архива"
			read NAMEnew
		else
			echo "Введи имя подпапки"
			read NAMEnew
		fi
	fi
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
	STR=`echo ${MINUTE[$N]}" "${HOUR[$N]}" "${DAY[$N]}" "${MONTH[$N]}" "${WEEKDAY[$N]}" "$1" "$N".cfg"" "$2 | sed "s/@/*/g"`
	echo "$STR" >> $3$4
	echo "PATHfrom0="$PATHfromnew > $5$N".cfg"
	echo "PATHto0="$PATHtonew >> $5$N".cfg"
	echo "NAME0="$NAMEnew >> $5$N".cfg"
	echo "ARCH0="$ARCHnew >> $5$N".cfg"
}

function DeleteTaskDialog(){ #$PATHTMP1 $PATHCONFIG $COMMAND $TEGGREP $FTMP1
	PrintCrontabTask
	echo "Введи номера удаляемых заданий через пробел"
	read strDeleteTaskDialog
	DeleteFewTask "$strDeleteTaskDialog" $1 $2 $3 $4 $5
}

function MainDialog(){
	choiceMainDialog=0
	echo "Привет чувак, я скрипт backup, что мне сделать:"
	while [[ $choiceMainDialog != 4 ]]
	do
		ReadCrontab $TEGGREP $PATHTMP1 $FTMP0 $FTMP1
		ReadCrontabStr $PATHTMP1$FTMP1
		PATHfromnew=
		PATHtonew=
		NAMEnew=
		ARCHnew=
		echo "1) Сделать резервную копию прям сейчас"
		echo "2) Создать, редактировать, удалить задание на автоматическое резервное копирование"
		echo "3) Показать уже имеющиеся задания на резервное копирование"
		echo "4) Ты зашел сюда случайно и хочешь выйти((("
		echo "PS Введи цифру и нажми Enter"
		read choiceMainDialog
		case $choiceMainDialog in
			1)
				CreateBackupNowDialog
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


CheckDir $PATHCONFIG
CheckDir $PATHTMP0
CheckDir $PATHTMP1

if [[ -n $1 ]]
then
	CarryOut $1 $2 $3 $4
else
	MainDialog
fi

exit 0
