 #!/bin/bash
ANSIBLE_USER="openmsa"
ANSIBLE_PASS="openmsa"
INSTALL_TYPE="client"
RESULT=0

initialize_args() {
    while [ $# -gt 0 ]
    do
        case $1 in
        -u|--user) 
            ANSIBLE_USER="$2" 
            shift
            ;;
        -p|--pass) 
            ANSIBLE_PASS="$2" 
            shift
            ;;
        # for options with required arguments, an additional shift is required
        -t|--type) 
            INSTALL_TYPE="$2"
            shift
            ;;
        (--) shift; break;;
        (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
        (*) break;;
        esac
        shift
    done
}

view_args() {
    echo "ANSIBLE_USER=$ANSIBLE_USER"
    echo "ANSIBLE_PASS=$ANSIBLE_PASS"
    echo "INSTALL_TYPE=$INSTALL_TYPE"
}

install_packages() {
    case $INSTALL_TYPE in
        server) 
            ;;
        client) 
            ;;
        (*) 
            echo "error - invalid install_type [$INSTALL_TYPE]" 1>&2
            echo "install_type shoud be'server' or 'client'"
            RESULT=1
            ;;
    esac
}

start_msg() {
    echo ""
    echo "###################################################"
    echo "##    [START] $* "
    echo "###################################################"
    echo ""
    RESULT=0
}

finish_msg() {
    echo ""
    echo "###################################################"
    echo "##    [FINISHED] $* "
    echo "###################################################"
    echo ""
    check_resultcode
}

check_resultcode() {
    if [ $RESULT -ne 0 ]
    then
        exit 1
    fi
}

## START Script 
initialize_args $*

COMM="Input parameters"
start_msg $COMM
view_args
finish_msg $COMM

# 1. 기본패키지 저장 (SSH)
COMM="Install Packages"
start_msg $COMM
install_packages
finish_msg $COMM

#2. OpenMSA 유저 생성 + Sudo 권한 부여
COMM="Create OpenMSA User"
start_msg $COMM
RESULT=$( ./create_user.sh -c -u $ANSIBLE_USER -p $ANSIBLE_PASS )
echo $RESULT
finish_msg $COMM

#3. Python 3.8 설치
COMM="ddd"
start_msg $COMM
# function 
finish_msg $COMM

#4. SSH 
COMM="initialize SSH Connection"
start_msg $COMM
# ansible-playbook auto_ssh_connect.yml --extra-vars "{\"ansible_user\":\"$ANSIBLE_USER\", \"ansible_password\":\"$ANSIBLE_PASS\"}"
finish_msg $COMM