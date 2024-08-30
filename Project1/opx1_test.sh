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

Task1=("cd /home/ec2-user/test5/test3;
mv MainSystem1 MainSystem1_B4_$release;
mv MainSystem2 MainSystem2_B4_$release;
mkdir MainSystem1 MainSystem2"
)


Task2=("amr; cd ${AM_AMSEARCH}/bin;./amPing.ksh > status.log;
result1=$(cat status.log);
while [[ "$result1" != *"UP"* ]]; do
    sleep 5
done"
)

Task3=("cd /home/ec2-user/test5/test3/MainSystem1;
touch Load.start;
result2=$(grep -i "Successfully Finished Loading Collections" Status.txt.log);
while [ $result2 != *"Successfully Finished Loading Collections"* ]; do
	echo "Waiting for startup..."
    	sleep 5
done"
)

Task3=("cd /home/ec2-user/test5/test3/MainSystem2;
touch Load.start;
result3=$(grep -i "Successfully Finished Loading Collections" Status.txt.log);
while [ $result3 != *"Successfully Finished Loading Collections"* ]; do
	echo "Waiting for startup..."
    	sleep 5
done"
)

echo "please enter the HF, the needs to deploy"
read "HF"

echo " please enter the release (ex: 2407)"
read "release"

cd /home/ec2-user/hotfix/HOTFIX/OPX/Release_$release/HF_$HF

VALIDATE $? "vaidation of HF is :"

Servers=("184.73.51.246"
"18.233.163.39")

User=ec2-user

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
	cd /home/ec2-user/Release_$release/HF_$HF
	scp -r * ${User}@${server}:/home/ec2-user/test5/test3/MainSystem1
 	scp -r * ${User}@${server}:/home/ec2-user/test5/test3/MainSystem2
done
VALIDATE $? "copy the code to OPX :"

##check the Start and status
echo -e "$G Startting the server $N"
for server in "${Servers[@]}"; do
	echo "Exicuting: task2 on $server"
	ssh "${User}@${server}" "${Task2}"
done
VALIDATE $? "Start up of OPX :"

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
