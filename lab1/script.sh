#!/bin/bash
echo "Введите путь где будут созданы каталоги"
read path
nfolders=5
nsubfolders=10
nfiles=20
while [ $nfolders -ne 0 ]
do
let 'a = nsubfolders'
	while [ $a -ne 0 ]
	do
	mkdir -p $path"f"$nfolders"/sf"$a
	let 'b = nfiles'
	# cd $path"/f"$nfolders"/sf"$a
		while [ $b -ne 0 ]
		do
		touch $path"f"$nfolders"/sf"$a"/emptyfile"$b".f"
		let 'b = b-1'
		done
	# cd -
	let 'a = a-1'
	done
let 'nfolders = nfolders-1'
done

exit 0
