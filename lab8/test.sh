#!/bin/bash

TEGGREP="#mybackup"

crontab -l | grep $TEGGREP > test.txt

