#!/bin/bash

# Argument is install_package_list (delimeter whitespace - " ")
PACKAGES=$*


# Exit Code List
{
    # 0 = Success
    # 1 = arguemnt empty
    # 2 = Failed apt-get update
}

usage() {
    echo "usage: $0 [package1 package2 ...]"
    echo "example) $0 curl wget net-tools :"
}

validate_packages() {
    if [ "${PACKAGES}" == "" ]; then
        echo "error - invalid PACKAGES[$PACKAGES]" 1>&2
        usage
        exit 1
    fi
}

update_apt_repo() {
    echo "Start apt-get update..."
    sudo apt-get update > /dev/null
    if [ $? -ne 0 ]; then
        exit 2
    fi
    echo "Finished apt-get update."
}

install_package() {
    for i in $PACKAGES
    do
        echo "Try install $i ..."
        sudo apt-get install $i -y > /dev/null
        if [ $? -eq 0 ] ; then
            echo "$i install finished."
        else
            echo "Failed install package [$i]"
        fi
    done
    exit 0
}

# Script main start
validate_packages
update_apt_repo
install_package


