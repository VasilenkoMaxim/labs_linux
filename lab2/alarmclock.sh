#!/bin/bash

#Ключ извлечения записей из crontab
KEYGREP="#alarmclock"
PLAYER="mpg123"
STARS=" * * * "


#Выключение будильников
if [[ $1 = "stop" ]]
then
	PIDs=`pidof mpg123`
	if [[ $PIDs != "" ]]
	then
		kill -9 $PIDs
		echo "Все работающие будильники были отключены"
		exit 0
	fi
	echo "Нет работающих будильников"
	exit 0
fi

#Извлечение записей из crontab и помещение их в файлы:
#actemp1.txt - помеченные ключом
#actemp0.txt - все остальные
crontab -l | grep $KEYGREP > actemp1.txt
crontab -l | grep -v $KEYGREP > actemp0.txt

#удаляем звездочки из записей будильника
sed -i 's/*//g' actemp1.txt

#Читаем построчно и разбиваем на слова и записываем в соответсвующие массивы
n=0 #количество установленных будильников
read s < actemp1.txt
sed -i "1d" actemp1.txt
while [[ $s != "" ]]
do
	a=($s)
	M[$n]=${a[0]}
	H[$n]=${a[1]}
	PTH[$n]=${a[3]}
	let 'n=n+1'
	read s < actemp1.txt
	sed -i "1d" actemp1.txt
done

i=0
echo "Текущие будильники их "$n
echo " №   H:M  Путь музыкального файла"
while [ $i -lt $n ]
do
let 'j=i+1'
printf '%2d) %02d:%02d %s\n' $j ${H[$i]} ${M[$i]} ${PTH[$i]}
let 'i=i+1'
done

echo ""
echo "Выберите действие: 1-удалить, 2-установить, 3-редактировать, 4-выход"

#Объединяем нетронутую часть записей и относящуюуся к будильнику,
#отправляем результат в crontab и удаляем временные файлы
#cat actemp0.txt actemp1.txt > actemp.txt
#crontab actemp.txt
#rm -f actemp.txt actemp0.txt actemp1.txt
echo "Будильники были успешно обновлены"

exit 0
