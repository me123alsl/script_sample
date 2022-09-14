#!/bin/bash

PY_REQUIRED=3.8
PY_PATH=""
PY_VERSION=0

check_python3() {
    if [ -f "/usr/bin/python3" ]
    then
        PY_PATH="/usr/bin/python3"
        PY_VERSION=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1.\2/')
    fi

    echo "PY3_PATH : $PY_PATH"
    echo "PY3_CURRENT_VERSION : $PY_VERSION"
    echo "PY3_REQUIRED_VERSION : $PY_REQUIRED"

    if [ 1 -eq "$(echo "$PY_VERSION < $PY_REQUIRED" | bc )" ]
    then
        install_python3.8
    else
        echo "good"
    fi
}

check_python() {
    if [ -f "/usr/bin/python" ]
    then
        PY_PATH="/usr/bin/python"
        PY_VERSION=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1.\2/')
    fi

    echo "PY_PATH : $PY_PATH"
    echo "PY_VER : $PY_VERSION"
    echo "PY_REQ : $PY_REQUIRED"

    if [ 1 -eq "$(echo "$PY_VERSION < $PY_REQUIRED" | bc )" ]
    then
        echo "Small"
    else
        echo "good"
    fi
 
}

install_python3.8 () {
    echo "Install Python [$PY_REQUIRED]"
    sudo apt-get install -qq python3.8 -y > /dev/null
    if [ $? = 0 ]
    then
        echo "Installed Python3.8"
        create_link_python
    else
        echo "Failed install python3.8"
        echo "install command 'sudo apt install python3.8' "
        echo ""
    fi
}

create_link_python() {
    sudo rm -f /usr/bin/python
    # sudo rm -f /usr/bin/python3
    sudo ln -s /usr/bin/python3.8 /usr/bin/python
    # sudo ln -s /usr/bin/python3.8 /usr/bin/python3
        if [ $? = 0 ]
    then
        echo "Success create symbolic link /usr/bin/python3.8 -> /usr/bin/python "
    else
        echo "Failed create symbolic link python3.8"
        echo "link command : 'sudo ln -s /usr/bin/python /usr/bin/python3.8' "
    fi
}

echo ""
echo "##################################################"
echo "### Check / Install python - requirement [$PY_REQUIRED]"
echo "##################################################"
check_python3
echo "##################################################"
echo "### Finished Check / Install python "
echo "##################################################"
echo ""

#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1