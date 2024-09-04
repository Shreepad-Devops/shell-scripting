#!/bin/bash

Time_Stamp="$date +%f_%H%M%S"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter the HF, the needs to deploy"
read "HF"

echo " please enter the release (ex: 2407)"
read "release"

Servers=("18.207.186.186"
"44.201.234.160")

User=ec2-user

VALIDATE(){
	if [ $1 -eq 0 ]
	then
		echo -e "$2 ...$G Success $N"
	else
		echo -e "$2 ...$R Failure $N"
        exit 1
	fi
}

Task1=("cd /home/ec2-user/test5/test3;
mv MainSystem1 MainSystem1_B4_$release;
mv MainSystem2 MainSystem2_B4_$release;
mkdir MainSystem1 MainSystem2"
)


Task2=("cd /home/$(User)/test5/test3;
sh startup.sh > status.log;
sh startuptest.sh"
)

Task3=("cd /home/$(User)/test5/test3/MainSystem1;
sh startmain1.sh > Status.txt.log;
sh loadstatus1.sh"
)

Task4=("cd /home/$(User)/test5/test3/MainSystem2;
sh startmain2.sh > Status.txt.log;
sh loadstatus2.sh"
)

cd /home/$(User)/hotfix/HOTFIX/OPX/Release_$release/HF_$HF

VALIDATE $? "vaidation of HF is :"

##Go to the location and take the back up and create the new folder
echo -e "$G Taking the backup and creating the new $N"

for server in "${Servers[@]}"; do
	echo "Exicuting: tasks on $server"
	ssh "${User}@${server}" "${Task1}"
done
VALIDATE $? "Creation of new folder and backup :"

##copy the code to OPX
echo -e "$G copying the code OPX $N"
for server in "${Servers[@]}"; do
	echo "Exicuting: tasks on $server"
	cd /home/ec2-user/hotfix/HOTFIX/OPX/Release_$release/HF_$HF
	scp -r * ${User}@${server}:/home/$(User)/test5/test3/MainSystem1
 	scp -r * ${User}@${server}:/home/$(User)/test5/test3/MainSystem2
done
VALIDATE $? "copy the code to OPX :"

##check the Start and status
echo -e "$G Startting the server $N"
for server in "${Servers[@]}"; do
	echo "Exicuting: task2 on $server"
	ssh "${User}@${server}" "${Task2}"
done
VALIDATE $? "Start and status :"

##collections load on MainSystem1
echo -e "$G collections load on MainSystem1 $N"
for server in "${Servers[@]}"; do
	ssh "${User}@${server}" "${Task3}"
done
VALIDATE $? "collections load on MainSystem1 :"

##collections load on MainSystem2
echo -e "$G collections load on MainSystem2 $N"
for server in "${Servers[@]}"; do
	ssh "${User}@${server}" "${Task4}"
done
VALIDATE $? "collections load on MainSystem2 :"
