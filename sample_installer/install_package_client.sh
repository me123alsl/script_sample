#!/bin/bash

set -eu -o pipefail # fail on error and report it, debug all lines

# check_privilege() {
#     sudo -n true
#     test $? -eq 0 || exit 1 "you should have sudo privilege to run this script"
# }

check_python() {
    if [ -f "/usr/bin/python" ]
    then
        PY_PATH="/usr/bin/python"
        # PY_VERSION = $(/usr/bin/python -V | awk '{print $2}')
        PY_VERSION=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
    elif [ -f "usr/bin/python3" ]
    then
        PY_PATH="/usr/bin/python3"
        # PY_VERSION = $(/usr/bin/python -V | awk '{print $2}')
        PY_VERSION=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
    else
        PY_PATH=""
        PY_VERSION=0
    fi

    if [ $PY_VERSION -lt 38 ]
    then
        install_python3
    fi
}

install_python3() {
    # Install Python 3.8
    sudo apt-get install -y python3.8
    # Already Python link file remove & New Python(3.8) creates symbolic link
    if [ -f /usr/bin/python3.8 ]
    then
        if [ -f /usr/bin/python ]
        then
            # remove python link file
            sudo rm -f /usr/bin/python
        fi
        # create symbolic link python -> python3
        sudo ln -s /usr/bin/python3.8 /usr/bin/python
        echo "Installed python3.8... "
    else
        echo "Not installed Python3.8... "
    fi
    PY_PATH="/usr/bin/python"
    PY_VERSION=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
}

install_package() {
    echo "installing pre-required package"
    sudo apt update

    # openssh-client, curl, wget
    PACKAGES = $(cat << EOF
curl
wget
openssh-client
EOF 
)
    while read p ; do
        sudo apt-get install -y $p 
    done < $PACKAGES
}


# Start Script
check_python

install_package