#!/bin/bash
USERID=$(id -u)
FILENAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%f%H%M%S)
LODFILE=/tmp/$FILENAME-$TIMESTAMP.log
echo "Enter the DB server name"
read SERVER_NAME
echo "Enter the password for datebase"
read -s PASS
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[33m"

if [ $USERID -ne 0 ]
then
    echo -e "Please swith to $R root user $N"
    exit 1
else
    echo -e "You are with root user, $G proceeding futher $N"
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2..$G SUCCESS $N"
    else
        echo -e "$2..$G FAILURE $N"
        exit 1
    fi
}

echo "checking the package for the installtion"
dnf list installed mysql &>> $LOGFILE
if [ $? -ne 0 ]
then
    dnf install mysql-server -y @>> $LOGFILE
    VALIDATE @? "Installtion of mysql:"
else
    echo -e "mysql is already installed..$Y SKIPPING $N"
fi

echo "enable of mysql" @>> $LOGFILE
systemctl enable mysqld
VALIDATE @? "enable of mysql:"

echo "Start of mysql" @>> $LOGFILE
systemctl start mysqld
VALIDATE @? "Start of mysql:"

echo "setting up the password for the root"
mysql -h$SERVER_NAME -uroot -p$PASS -e 'show databases;' @>> $LOGFILE
if [ $? -eq 0 ]
then
    echo "Password is already set for the user root"
else
    mysql_secure_installation --set-root-pass ExpenseApp@1 @>> $LOGFILE
    VALIDATE @? "Password set for user:"
fi



