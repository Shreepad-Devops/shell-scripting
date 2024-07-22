#!/bin/bash

USERID=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
Source_Dir=/home/ec2-user/shell-scripting/Project1
DB_Server_IP=172.31.58.66
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -eq 0 ]
then
    echo "Proceeding installtion with root user"
else
    echo -e "Please swith to $R root $N user"
    exit 1
fi

VALIDATE(){
if [ $1 -eq 0 ]
then
    echo -e "$2 ...$G Success $N"
else
    echo -e "$2 ...$R Failure $N"
fi
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "nodejs module disable"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "nodejs module enable"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "nodejs install is"

id expense
if [ $? -eq 0 ]
then
    echo "This user is already exist"
else
    useradd expense &>> $LOGFILE
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating the app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOGFILE
VALIDATE $? "download the application"

cd /app
unzip /tmp/backend.zip &>> $LOGFILE
VALIDATE $? "extract the application"

cd /app
npm install &>> $LOGFILE
VALIDATE $? "download the dependencies"

cp $Source_Dir/backend.service /etc/systemd/system/ &>> $LOGFILE
VALIDATE $? "Setup of SystemD Expense Backend Service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Load the service"

systemctl start backend &>> $LOGFILE
systemctl enable backend &>> $LOGFILE
VALIDATE $? "Start the service"

dnf list installed mysql &>> $LOGFILE
if [ $? -eq 0 ]
then
    echo -e "my sql is already installed....$Y SKIPPING $N"
else
    dnf install mysql -y &>> $LOGFILE
    VALIDATE $? "install mysql client"
fi

mysql -h $DB_Server_IP -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOGFILE
VALIDATE $? "Load Schema"

systemctl restart backend &>> $LOGFILE
VALIDATE $? "Restart the service"