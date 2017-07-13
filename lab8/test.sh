#!/bin/bash

TEGGREP="#mybackup"


crontab -l | grep $TEGGREP > test0.txt
crontab -l | grep -v $TEGGREP > test1.txt
