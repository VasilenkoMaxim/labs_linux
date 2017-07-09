#!/bin/bash
echo "Введите путь где будут удаляться каталоги"
read path

nfolders=`find $path -maxdepth 1 -type d | wc -l`
let 'nfolders=nfolders-1'
nsubfolders=`find $path -maxdepth 2 -type d | wc -l`
let 'nsubfolders=(nsubfolders-nfolders-1)/nfolders'
nfiles=`find $path -maxdepth 3 -type f | wc -l`
let 'nfiles=nfiles/nfolders/nsubfolders'

echo "Выберете способ удаления файлов их "$nfiles" штук: 1 - все, 2 - с до, 3 - перечилите через пробел, 4 - ничего"
read change

case $change in
1)
rm -f `find $path -maxdepth 3 -type f`
;;
2)
echo "Введите через пробел два числа от 1 до "$nfiles
read from to
while [ $from -le $to ]
do
rm -f `find $path -maxdepth 3 -name "emptyfile"$from".f" -type f`
let 'from=from+1'
done
;;
3)
echo "Введите через пробел номера от 1 до "$nfiles
read n
for i in $n
do
rm -f `find $path -maxdepth 3 -name "emptyfile"$i".f" -type f`
done
;;
4)
echo "ни один файл не был удален"
;;
*)
echo "Введено неправилное действие"

esac #окончание оператора case

echo "Выберете способ удаления подкаталогов их "$nsubfolders" штук: 1 - все, 2 - с до, 3 - перечилите через пробел 4 - ничего"
read change

case $change in
1)
rm -rf `find $path -maxdepth 2 -name "sf*" -type d`
;;
2)
echo "Введите через пробел два числа от 1 до "$nsubfolders
read from to
while [ $from -le $to ]
do
rm -rf `find $path -maxdepth 2 -name "sf"$from -type d`
let 'from=from+1'
done
;;
3)
echo "Введите через пробел номера от 1 до "$nsubfolders
read n
for i in $n
do
rm -rf `find $path -maxdepth 2 -name "sf"$i -type d`
done
;;
4)
echo "ни один подкаталог не был удален"
;;
*)
echo "Введено неправилное действие"

esac #окончание оператора case

echo "Выберете способ удаления каталогов их "$nfolders" штук: 1 - все, 2 - с до, 3 - перечилите через пробел 4 - ничего"
read change

case $change in
1)
rm -rf `find $path -maxdepth 1 -name "f*" -type d`
;;
2)
echo "Введите через пробел два числа от 1 до "$nfolders
read from to
while [ $from -le $to ]
do
rm -rf `find $path -maxdepth 1 -name "f"$from -type d`
let 'from=from+1'
done
;;
3)
echo "Введите через пробел номера от 1 до "$nfiles
read n
for i in $n
do
rm -rf `find $path -maxdepth 2 -name "f"$i -type d`
done
;;
4)
echo "ни один подкаталог не был удален"
;;
*)
echo "Введено неправилное действие"

esac #окончание оператора case
