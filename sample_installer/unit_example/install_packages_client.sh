#!/bin/sh

PACKAGES="
curl
wget
openssh-client
"

install_package() {
    echo "installing pre-required package"
    sudo apt update

    for i in $PACKAGES
    do
        sudo apt install $i -y 
    done
}

install_package