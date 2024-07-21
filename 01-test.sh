#!/bin/bash

USRID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

if [ $USRID -eq 0 ]
then
    echo "$G you are with root user, so proceding with instation $N"
else
    echo "$G please shiwch to root user $N"
fi