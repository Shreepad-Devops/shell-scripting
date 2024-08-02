#!/bin/bash

Time_Stamp="$date +%f_%H%M%S"
LogFile = /petnas/vfk/genadm/Shreepad/Scripts/test_$Time_Stamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
	if [ $1 -eq 0 ]
	then
		echo -e "$2 ...$G Success $N"
	else
		echo -e "$2 ...$R Failure $N"
        exit 1
	fi
}

echo "please enter the HF, the needs to deploy"
read "HF"

echo " please enter the release (ex: 2407)"
read "release"

cd /home/ec2-user/hotfix/HOTFIX/OPX/Release_$release/HF_$HF

VALIDATE $? "vaidation of HF is :"

echo "testing" 