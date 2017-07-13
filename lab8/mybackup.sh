#!/bin/bash

#Ключ извлечения записей из crontab
KEYGREP=" #mybackup"
ARCH="arch"
SYNC="sync"
DD="dd"
PATHfrom=""
PATHto=""
STARS=" * * "

source mybackup.cfg

echo "${H[0]}" >> test.txt
echo "${H[1]}" >> test.txt
echo "${H[2]}" >> test.txt


choice=0
echo "Привет чувак, я скрипт backup, что мне сделать:"
while [[ $choice != 4 ]]
do
	echo "1) Сделать резервную копию прям сейчас"
	echo "2) Создать, редактировать, удалить задание на автоматическое резервное копирование"
	echo "3) Показать уже имеющиеся задания на резервное копирование"
	echo "4) Ты зашел сюда случайно и хочешь выйти((("
	echo "PS Введи цифру и нажми Enter"
	read choice

	case $choice in
		1)
			echo "Что ты хочешь скопировать, введи путь директории или укажи блочное устройство"
			read PATHfrom
			echo "Куда это скопировать, введи путь директории"
			read PATHto
			if [[ -b $PATHfrom ]]
			then
				echo "Ты указал блочное устройство, введи имя ISO файла"
				read NAME
				echo "Возможно придется долго ждать, дождись завершения процесса"
				echo "или нажми Ctr+c, тогда все прервется и данные могут быть повреждены"
				sudo dd if=$PATHfrom of=$PATHto$NAME".iso"
				if [[ $? = 0 ]]
				then
					echo "Данные успешно скопированы"
				else
					echo "Что-то пошло не так, попробуй еще раз"
				fi
			else
				echo "Нужно ли архивирование? (y/n)"
				read choiceARCH
				if [[ $choiceARCH = "y" ]]
				then
					echo "Введи имя архива"
					read NAME
					cd $PATHfrom && tar -czf $PATHto$NAME".tgz" *
					if [[ $? = 0 ]]
					then
						echo "Данные успешно скопированы"
					else
						echo "Что-то пошло не так, попробуй еще раз"
					fi
				else
					echo "Введи имя подпапки"
					read NAME
					cd $PATHfrom && rsync -zr * $PATHto$NAME"/"
					if [[ $? = 0 ]]
					then
						echo "Данные успешно скопированы"
					else
						echo "Что-то пошло не так, попробуй еще раз"
					fi
				fi

			fi

		;;
		2)

		;;
		3)
		
		;;
		4)
		exit 0
		;;
		*)
		echo "Чувааак, ты ошибся с вводом, попробуй еще раз"		
	esac
done

exit 0
# case $1 in
# 	$ARCH)
# 	#echo "Архивирование каталога"
# 		cd $2
# 	;;
# 	$SYNC)
# 	echo "Синхронизация каталога"
# 	;;
# 	$DD)
# 	echo "Создание iso образа устройства"
# 	;;
# 	*)
# 	echo "Неправильный ввод"
# 	;;
# esac

# exit 0
# #Выключение будильников
# if [[ $1 = "stop" ]]
# then
	
# fi

# #Извлечение записей из crontab и помещение их в файлы:
# #actemp1.txt - помеченные ключом
# #actemp0.txt - все остальные
# crontab -l | grep $KEYGREP > actemp1.txt
# crontab -l | grep -v $KEYGREP > actemp0.txt



# choice=0
# while [[ $choice != 4 ]]
# do
# 	#удаляем звездочки из записей будильника
# 	sed -i 's/*//g' actemp1.txt
# 	#Читаем построчно и разбиваем на слова и записываем в соответсвующие массивы
# 	n=0 #количество установленных будильников
# 	read s < actemp1.txt
# 	sed -i "1d" actemp1.txt
# 	while [[ $s != "" ]]
# 	do
# 		a=($s)
# 		M[$n]=${a[0]}
# 		H[$n]=${a[1]}
# 		PTH[$n]=${a[3]}
# 		let 'n=n+1'
# 		read s < actemp1.txt
# 		sed -i "1d" actemp1.txt
# 	done
# 	i=0
# 	echo "Текущие будильники, их "$n
# 	echo " №   H:M  Путь музыкального файла"
# 	while [ $i -lt $n ]
# 	do
# 	let 'j=i+1'
# 	printf '%2d) %02d:%02d %s\n' $j ${H[$i]} ${M[$i]} ${PTH[$i]}
# 	echo "${M[$i]} ${H[$i]}$STARS$PLAYER${PTH[$i]}$KEYGREP" >> actemp1.txt
# 	let 'i=i+1'
# 	done

# 	echo ""
# 	echo "Выберите действие: 1-удалить, 2-добавить, 3-редактировать, 4-выход"
# 	echo "ВСЕ ИЗМЕНЕНИЯ ВСТУПЯТ В СИЛУ ТОЛЬКО ПРИ КОРРЕКТНОМ ВЫХОДЕ"
# 	read choice

# 	case $choice in
# 	1)
# 	echo "Введите номера будильников которые нужно удалить, всего будильников "$n
# 	read N
# 	for i in $N
# 	do
# 		sed -i "$i"d"" actemp1.txt
# 	done
# 	echo "Бдильники "$N" успешно удалены"
# 	;;
# 	2)
# 	let 'n=n+1'
# 	echo "Введите час"
# 	read H[$n]
# 	echo "Введите минуты"
# 	read M[$n]
# 	echo "Введите путь музыкального файла"
# 	read PTH[$n]
# 	#Хорошо бы добавить проверку введеных даных на адекватность
# 	echo "${M[$n]} ${H[$n]}$STARS$PLAYER${PTH[$n]}$KEYGREP" >> actemp1.txt
# 	echo "Успешно добавлен новый будильник"
# 	;;
# 	3)
# 	echo "Введите номера будильников который нужно отредактировать, всего будильников "$n
# 	read N
# 	let 'k=N-1'
# 	echo "Введите новый час, для будильника № "$N
# 	read Ht
# 	if [[ $Ht != "" ]]
# 	then
# 		H[$k]=$Ht;
# 	fi
# 	echo "Введите новые минуты, для будильника № "$N
# 	read Mt
# 	if [[ $Mt != "" ]]
# 	then
# 		M[$k]=$Mt
# 	fi
# 	echo "Введите путь музыкального файла, для будильника № "$N
# 	read PTHt
# 	if [[ $PTHt != "" ]]
# 	then
# 		PTH[$k]=$PTHt
# 	fi
# 	rm -f actemp1.txt
# 	i=0
# 	while [ $i -lt $n ]
# 	do
# 	let 'j=i+1'
# 	echo "${M[$i]} ${H[$i]}$STARS$PLAYER${PTH[$i]}$KEYGREP" >> actemp1.txt
# 	let 'i=i+1'
# 	done
# 	;;
# 	4)
	
# 	;;
# 	*)
	
# 	;;
	
# 	esac
# done
# 	#Объединяем нетронутую часть записей и относящуюуся к будильнику,
# 	#отправляем результат в crontab и удаляем временные файл
# 	cat actemp0.txt actemp1.txt > actemp.txt
# 	crontab actemp.txt
# 	rm -f actemp.txt actemp0.txt actemp1.txt
# 	echo "Будильники были успешно обновлены"

# exit 0
