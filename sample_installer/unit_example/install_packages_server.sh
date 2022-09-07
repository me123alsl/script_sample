#!/bin/sh

PACKAGES="
software-properties-common
openssh-server
sshpass
ansible
tree
curl
wget
"

install_package() {
    echo "installing pre-required package"
    sudo apt update
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    for i in $PACKAGES
    do
        sudo apt install $i -y 
    done
}

install_package