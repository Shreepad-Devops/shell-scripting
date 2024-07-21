#!/bin/bash

USRID=$(id -u)
if ($USRID -eq 0)
R="\e[31m"
G="\e[32m"
N="\e[0m"
then
    echo "$G you are with root user, so proceding with instation $N"
else
    echo "$G please shiwch to root user $N"