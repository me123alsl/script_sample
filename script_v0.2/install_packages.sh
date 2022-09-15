#!/bin/bash
PACKAGES=$*

# Exit Code List
    # 0 = Success
    # 1 = arguemnt empty
    # 2 = Failed apt-get update

# Argument is install_package_list (delimeter whitespace - " ")
usage() {
    echo "Usage :"
    echo "  $0 pkg1 pkg2 pkg3..."
    echo "Example :"
    echo "  $0 curl wget net-tools"
    exit 1
}

validate_packages() {
    if [ "${PACKAGES}" == "" ]; then
        echo "error - invalid packages [ $PACKAGES ]" 1>&2
        usage
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
            echo "Failed install package '$i'"
        fi
    done
    exit 0
}

# Script main start
if [ $# -eq 0 ]; then
    usage
fi

if [[ $1 == "help" ] || [ $1 == "-help" ] || [ $1 == "--help" ] || [ $1 == "-h" ] || [ $1 == "h" ]]; then 
    usage 
fi
validate_packages
update_apt_repo
install_package


