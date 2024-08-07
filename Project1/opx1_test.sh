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

Servers=("184.73.51.246"
"18.233.163.39")

User=ec2-user

Tasks=("cd /home/ec2-user/test4;	
mkdir test_01;
touch opx"
)

for server in "${Servers[@]}"; do
	echo "Exicuting: tasks on $server"
	ssh "${User}@${server}" "${Tasks}"
done

for server in "${Servers[@]}"; do
	echo "Exicuting: tasks on $server"
	cd /home/ec2-user/test3
	scp -r * ${User}@${server}:/home/ec2-user/test5/
done

for server in "${Servers[@]}"; do
	cd /home/ec2-user/test5/test3
	sh Load.sh
	result=grep "Successfully Finished Loading Collections" Status.txt.log	
	while [[ $result != *"Successfully Finished Loading Collections"* ]]; do
    echo "Waiting for startup..."
    sleep 2
    done
done