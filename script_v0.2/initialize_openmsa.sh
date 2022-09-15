#!/bin/bash

ANSIBLE_USER="openmsa"
ANSIBLE_PASS="openmsa"
INSTALL_TYPE="client"
READ_SERVER_TYPE=""
MANAGED_SERVER=""
RESULT=0

usage() {
        echo "Usage : $0 [-u|--user 생성할 계정] [-p|--password 계정 암호] [-t|--type 설치타입(server,client)]"
        echo ""
        echo "설치타입 server 인 경우"
        echo "     [-f|--file Serverlist File Path"
        echo "     [-s|--servers Serverlist File Path"
        echo "e.g. serverList는 linebreak 기준으로 작성"
        echo ""
        echo "ex)"
        echo " foo.example.com"
        echo " bar.example.com"
        echo " ..."
        echo ""
}

# 각 옵션에 맞는 파라미터 입력
# 예 $0 -u openmsa -p openmsa -t server -f "./serverlist.txt"
# 예 $0 -u openmsa -p openmsa -t server -s "192.168.1.1 192.168.1.2 192.168.1.3"
# 예 $0 -u openmsa -p openmsa -t client
initialize_args() {
    while [ $# -gt 0 ]
    do
        case $1 in
        # 계정 생성 설정
        # -u 옵션(필수) : 계정 명
        # -p 옵션(필수) : 계정 암호
        # -t 옵션(필수) : 설치할 서버 타입 (client, server).
        -u|--user) 
            ANSIBLE_USER="$2" 
            shift
            ;;
        -p|--password) 
            ANSIBLE_PASS="$2" 
            shift
            ;;
        # for options with required arguments, an additional shift is required
        -t|--type) 
            INSTALL_TYPE="$2"
            shift
            ;;

        # server 타입 일 경우, 매니지드 서버 목록
        # -s 옵션 : ,(comma)단위로 작성
        # -f 옵션 : file 경로 설정. 줄넘김 단위
        -f|--file)
            READ_SERVER_TYPE="FILE"
            MANAGED_SERVER="$2"
            shift
            ;;
            
        -s|--servers)
            shift
            READ_SERVER_TYPE="COMMAND"
            MANAGED_SERVER="$*"
            echo "MANAGED_SERVER='$*'"
            shift
            ;;

        (--) shift; break;;
        (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
        (*) break;;
        esac
        shift
    done
}

# 입력된 아규먼트 출력
view_args() {
    echo "ANSIBLE_USER=$ANSIBLE_USER"
    echo "ANSIBLE_PASS=$ANSIBLE_PASS"
    echo "INSTALL_TYPE=$INSTALL_TYPE"
    if [ $INSTALL_TYPE == "server" ]
    then
        echo "MANAGED_SERVER=$MANAGED_SERVER"
    fi
}

#필수 패키지 SSH, CURL, WGET 등 설치
initialize_packages() {
    case $INSTALL_TYPE in
        server) 
           PACKAGES="
            software-properties-common
            openssh-server
            sshpass
            ansible
            tree
            curl
            wget
            "   
            ;;  
        client) 
            PACKAGES="
            curl
            wget
            openssh-client
            "
            ;;
        (*) 
            echo "error - invalid install_type [$INSTALL_TYPE]" 1>&2
            echo "install_type shoud be'server' or 'client'"
            RESULT=1
            ;;
    esac
}

# install_package() {
#     if [ "${PACKAGES}" == "" ]
#     then
#         echo "error - invalid PACKAGES[$PACKAGES]" 1>&2
#         echo "install_type shoud be'server' or 'client'"
#         return 1
#     else
#         echo "installing pre-required package : ${PACKAGES}"
#         sudo apt-get update > /dev/null
#         # sudo add-apt-repository --yes --update ppa:ansible/ansible
#         for i in $PACKAGES
#         do
#             echo "Try install $i ..."
#             sudo apt-get install $i -y > /dev/null
#             if [ $? -eq 0 ] ; then
#                 echo "$i install finished."
#             else
#                 echo "Failed install package [$i]"
#             fi
#         done
#         return 0
#     fi
# }

# 시작 메시지 및 결과값 초기화 (RESULT=0)
start_msg() {
    echo ""
    echo "###################################################"
    echo "##    [START] $* "
    echo "###################################################"
    echo ""
    RESULT=0
}

# 종료 매시지 및 결과값 ($RESULT=0 정상)
finish_msg() {
    echo ""
    echo "###################################################"
    echo "##    [FINISHED] $* "
    echo "###################################################"
    echo ""
    check_resultcode
}

# 결과값 비교 (0이 아닌 경우, 종료)
check_resultcode() {
    echo "71 line = $RESULT"
    if [ $RESULT -ne 0 ]
    then
        exit 1
    fi
}

# target host 생성
initialize_targetserver() {
    if [ "${MANAGED_SERVER}" == "" ]
    then
        echo "Managed server is empty"
    else
        target_hosts=$MANAGED_SERVER
    fi
}

## START Script 
{
    initialize_args $*
    initialize_packages
    initialize_targetserver
}

# 아규먼트 출력 
{
    COMM="Input parameters"
    start_msg $COMM
    view_args
    finish_msg $COMM
}

# 1. 기본패키지 저장 (SSH) 
{
    COMM="Install pre-required Packages"
    start_msg $COMM
    ./install_package "$PACKAGES"
    finish_msg $COMM
}

#2-1. OpenMSA 유저 생성 + Sudo 권한 부여 
{
    COMM="Create OpenMSA User"
    start_msg $COMM
    ./create_user.sh -c -u $ANSIBLE_USER -p $ANSIBLE_PASS
    RESULT=$?
    echo $RESULT
    finish_msg $COMM
}

#3. Python 3.8 설치 
{
    COMM="Installation Python"
    start_msg $COMM
    ./check_python.sh 
    finish_msg $COMM
}



# create ssh-key rsa
{
    generate_ssh_key() {
        echo -n $ANSIBLE_PASS | sudo -S  su - $ANSIBLE_USER -c "ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ''" 
    }
}

# copy-ssh
{
    copy-ssh() {
        echo "target_hosts = $target_hosts"
        for host in ${target_hosts}; do
            echo "Start ssh-copy-id at [$host] "
            echo -n $ANSIBLE_PASS | sudo -S  su - $ANSIBLE_USER -c "
            sshpass -p $ANSIBLE_PASS ssh-copy-id -o StrictHostKeyChecking=no $ANSIBLE_USER@$host
            " 
            echo "Finished ssh-copy-id at [$host] "
        done
    }
}

# #4-2. Set SSH to 'ssh-copy-id'
{
    if [ $INSTALL_TYPE == "server" ]
    then
        echo "target_hosts = $target_hosts"
        COMM="initialize SSH Connection"
        start_msg $COMM
        generate_ssh_key
        copy-ssh
        finish_msg $COMM
    fi
}