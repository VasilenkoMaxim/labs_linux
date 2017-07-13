#!/bin/bash

TEGGREP="#mybackup"

#Чатаем файл crontab и разделяем записи с тегом TEGGREP и остальные, и складываем все в разные файлы
crontab -l | grep $TEGGREP > test0.txt
crontab -l | grep -v $TEGGREP > test1.txt
