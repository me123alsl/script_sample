#! /bin/bash

usage() {
    echo "Usage: $0 [-n USER_NAME] [-p USER_PASSWORD]";
}

# Variable
USER_NAME=
USER_PASSWD=


# Get Options Process
while getopts :u:p opt
do
    case $opt in
            u) 
                echo "NAME IS $OPTARG"
                USER_NAME=${OPTARG}
                ;;
            p) 
                echo "PASSWORD IS $OPTARG"
                USER_PASSWD=${OPTARG}
                ;;
            *) 
                echo "invalid options : ${OPTARG}"
                usage
                ;;
    esac
done


# Add User
sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER_NAME $USER_NAME

# Settings Password
echo "$USER_NAME:$USER_PASSWD" | sudo chpassw

# Add Sudo Group Auth
sudo usermod -aG sudo $USER_NAME