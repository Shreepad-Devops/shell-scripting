#!/bin/bash

USERID=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -eq 0 ]
then
    echo -e "you are already with $G ROOT user $N, proceeding further"
else
    echo -e "please swith to $R super User $N and try"
    exit 1
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 ..... $G SUCCESS $N"
    else
        echi -e "$2 ..... $R FAILURE $N"
    fi
}

dnf install nginx -y &>> LOGFILE
VALIDATE $? "Install of Nginx :"

systemctl enable nginx &>> LOGFILE
VALIDATE $? "Enableing nginx :"

systemctl start nginx &>> LOGFILE
VALIDATE $? "Start nginx :"

rm -rf /usr/share/nginx/html/* &>> LOGFILE
VALIDATE $? "Remove the default content that web server is serving :"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> LOGFILE
VALIDATE $? "Download the pkg :"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> LOGFILE
VALIDATE $? "Extract the frontend content :"

cp /home/ec2-user/shell-scripting/Project1/expense.conf /etc/nginx/default.d/

systemctl restart nginx &>> LOGFILE
VALIDATE $? "Start nginx"

