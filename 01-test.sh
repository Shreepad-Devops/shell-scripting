#!/bin/bash

USRID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"

if [ $USRID -eq 0 ]
then
    echo -e "$G you are with root user, so proceding with instation $N"
    exit 1
else
    echo -e "$R please shiwch to root user $N"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $i is already installed $N"
        exit 1
    else
        echo -e "$G proceeding with the instalation of $1"
    fi
}

for i in $@
do
    echo "Checking for the package : $i"
    dnf list installed $i &>>$LOGFILE
    VALIDATE $? "installion of $i"
    dnf install $i -y &>>$LOGFILE
done