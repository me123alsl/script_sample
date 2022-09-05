#! /bin/bash

# Variable
#USER_NAME=
#USER_PASSWD=
#RUN_TYPE=

# View Usage Format
usage() {
    echo "usage: $0 [-c | -r]  [-u USER_NAME] [-p USER_PASSWORD]"
    echo " -c : Create user"
    echo " -r : Remove user"
    echo " -u : User Name"
    echo " -p : User Password (when remove user)"
    exit 0
}


# Check Existing
exist_user() {
	if id -u "$USER_NAME" >/dev/null 2>&1; 
	then
		echo "user exists"
		EXIST_USER=1

	else
		echo "user does not exist"
		EXIST_USER=0
	fi
}

add_user() {
	sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER_NAME --gecos "" $USER_NAME
	if [ $? -ne 0 ] 
	then
		echo "Failed create user=[$USER_NAME]"
		exit
	else
		echo "Succeed create user=[$USER_NAME]"
		set_password
	fi
}

set_password() {
	echo "$USER_NAME:$USER_PASSWD" | sudo chpasswd
	if [ $? -ne 0 ]
        then
                echo "Failed set password=[$USER_NAME:$USER_PASSWD]"
                exit
        else
		echo "Succeed set password=[$USER_NAME:$USER_PASSWD]"
              	add_sudo_group
        fi
}

add_sudo_group() {
	sudo usermod -aG sudo $USER_NAME
	if [ $? -ne 0 ]
        then
                echo "Failed set 'sudo' permission=[$USER_NAME]"
                exit
        else
		echo "Succeed set 'sudo' permission=[$USER_NAME]"
		finished
        fi
}

del_user() {
	sudo userdel -r $USER_NAME
        if [ $? -ne 0 ]
        then
                echo "Failed remove user=[$USER_NAME]"
                exit
        else
                echo "Succeed remove user=[$USER_NAME]"
                finished
        fi

}

finished() {
	echo "##### COMPLETED $RUN_TYPE USER ######"
	exit
}



# Get Options Process

while getopts u:p:cr opt
do
    case $opt in
	    c)
                RUN_TYPE="CREATE"
		;;
            r)
                RUN_TYPE="REMOVE"
		;;
            u)
                USER_NAME=${OPTARG}
                echo "NAME IS $USER_NAME"
                ;;
	    p)
                USER_PASSWD=${OPTARG}
                echo "PASSWORD IS $USER_PASSWD"
                ;;
            *)
                echo "invalid options : ${OPTARG}"
                usage
                ;;
    esac
done
#shift $((OPTIND - 1))

if [ -z $RUN_TYPE ]
then
	echo "invalid run type. Use '-c' or '-r'"
	usage
	exit 1
fi

exist_user

echo "##RUN_TYPE : $RUN_TYPE"
echo "##EXIST_USER: $EXIST_USER"

if [ $RUN_TYPE = "CREATE" ] && [ $EXIST_USER -eq 0 ]
then
	add_user
	exit 0
fi

if [ $RUN_TYPE = "REMOVE" ] && [ $EXIST_USER -eq 1 ]
then
	del_user
	exit 0
fi




