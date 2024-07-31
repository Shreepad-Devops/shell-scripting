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
fi
}

echo "please enter the HF, the needs to deploy"
read "HF"

echo " please enter the release (ex: 2407)"
read "release"

cd /petnas/vfk/genadm/hotfix/HOTFIX/OPX/Release_$release/HF_$HF

VALIDATE $? "vaidation of HF is :"

#login to OPX and start the OPX if not started.
for i in [ ukpe03vr, ukpe04vr ]
do
	ssh petopx1@$i

#check the status
cd ${AM_AMSEARCH}/bin;./amPing.ksh > status.log
result=cat $status.log
if [ $result = UP ]
then
	echo -e "$G server is already up and running $N"
else
	echo "starting the opx1"
	amr
fi

cd ${AM_AMSEARCH}/bin;./amPing.ksh > status1.log
result=cat $status1.log
while [[ $result != *"up"* ]]; do
    echo "Waiting for startup..."
    sleep 5
done

#Go to the location and take the back up and create the new folder

for i in [ ukpe03vr, ukpe04vr ]
do
	ssh petopx1@$i;
	/opxnas/opx/$i/AMSearch/amsearch-support/data/
	mv MainSystem1 MainSystem1_B4_$release; mv MainSystem2 MainSystem2_B4_$release;
	mkdir MainSystem1 MainSystem2
done

VALIDATE $? "back up is :"

#code copy

for i in [ ukpe03vr, ukpe04vr ]
do
	cd /petnas/vfk/genadm/hotfix/HOTFIX/OPX/Release_$release/HF_$HF
	scp * prdopx1@$i:/opxnas/opx/$i/amsearch-support/data/MainSystem1
	scp * prdopx1@$i:/opxnas/opx/$i/amsearch-support/data/MainSystem2
done

VALIDATE $? "code copy is :"

#load the collections. 
for i in [ ukpe03vr, ukpe04vr ]
do
	scp * prdopx1@$i:/opxnas/opx/$i/amsearch-support/data/MainSystem1
	touch Load.start
	result=grep -i "Successfully Finished Loading Collections" Status.txt.log	
	while [[ $result != *"Successfully Finished Loading Collections"* ]]; do
    echo "Waiting for startup..."
    sleep 5
done
VALIDATE $? "collections load on MainSystem1 is :"

for i in [ ukpe03vr, ukpe04vr ]
do
	scp * prdopx1@$i:/opxnas/opx/$i/amsearch-support/data/MainSystem2
	touch Load.start
	result=grep -i "Successfully Finished Loading Collections" Status.txt.log	
	while [[ $result != *"Successfully Finished Loading Collections"* ]]; do
    echo "Waiting for startup..."
    sleep 5
done
VALIDATE $? "collections load on MainSystem1 is :"
