 #!/bin/bash
ANSIBLE_USER="openmsa"
ANSIBLE_PASS="openmsa"
INSTALL_TYPE="client"
INSTALL_PACKAGES=""
MANAGED_SERVER=""
RESULT=0

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
        -s|--servers)
            MANAGED_SERVER="$2"
            shift
            ;;
        -f|--file)
            MANAGED_SERVER="$2"
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
    if [ $INSTALL_TYPE == "server" ]
    then
        echo "MANAGED_SERVER=$MANAGED_SERVER"
    fi
}

install_packages() {
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

install_package_server() {
    if [ "${PACKAGES}" == "" ]
    then
        echo "TEST"
    else
        echo "installing pre-required package"
        echo ${PACKAGES}
    #     sudo apt update
    #     sudo add-apt-repository --yes --update ppa:ansible/ansible
    #     for i in $PACKAGES
    #     do
    #         sudo apt install $i -y 
    #     done
    fi
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
    echo "71 line = $RESULT"
    if [ $RESULT -ne 0 ]
    then
        exit 1
    fi
}

create_ansible_hosts() {
    if [ -z $MANAGED_SERVER ]
    then
        echo "$MANAGED_SERVER"
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

#2-1. OpenMSA 유저 생성 + Sudo 권한 부여
COMM="Create OpenMSA User"
start_msg $COMM
./create_user.sh -c -u $ANSIBLE_USER -p $ANSIBLE_PASS
RESULT=$?
echo $RESULT
finish_msg $COMM

#3. Python 3.8 설치
COMM="Installation Python"
start_msg $COMM
./check_python.sh 
finish_msg $COMM



#4-1. Set SSH to 'ansible'
if [ $INSTALL_TYPE == "server" ]
then
    COMM="Create ansible hosts file"
    start_msg $COMM
    create_ansible_hosts
    finish_msg $COMM

    COMM="initialize SSH Connection"
    start_msg $COMM
    ansible-playbook auto_ssh_connect.yml --extra-vars "{\"ansible_user\":\"$ANSIBLE_USER\", \"ansible_password\":\"$ANSIBLE_PASS\"}"
    finish_msg $COMM
fi


#4-2. Set SSH to 'ssh-copy-id'
install_packages
install_package_server