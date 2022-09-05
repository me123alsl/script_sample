#!/bin/bash

set -eu -o pipefail # fail on error and report it, debug all lines

check_privilege() {
    sudo -n true
    test $? -eq 0 || exit 1 "you should have sudo privilege to run this script"
}

check_python() {
    if [ -f "/usr/bin/python" ]
    then
        PY_VERSION = $(/usr/bin/python -V | awk '{print $2}')
    elif [ -f "usr/bin/python3" ]
    then
        PY_VERSION = $(/usr/bin/python -V | awk '{print $2}')
    else
        PY_VERSION = 0
    fi
}

install_package() {
    echo "installing pre-required package"
    sudo apt update
    while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
        openssh-server
        ansible
        tree
        sshpass
 
        curl
        wget
    EOF
    )
}