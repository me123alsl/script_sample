#!/bin/bash

usage() {
        echo "Usage : "
        echo "$0 -u [username] -p [password] -s host_list"
        echo "host_list='host1 host2 host3 ...'"
        echo "host_list in delimiter is whitespace(' ')"
        echo ""
}

initialize_args() {
    while [ $# -gt 0 ]
    do
        case $1 in
        -u) 
            USER="$2"
            shift
            ;;
        -p) 
            PASS="$2"
            shift
            ;;
        -s)
            shift
            TARGET_HOSTS="$*"
            shift
            ;;
        (--) shift; break;;
        (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
        (*) break;;
        esac
        shift
    done
}

generate_ssh_key() {
    # USER_HOME=$(echo -n $PASS | sudo -S  su - $USER -c "echo $HOME")
    USER_HOME="/home/$USER"
    if [ -f "$USER_HOME/.ssh/id_rsa" ]; then
        echo "SKIPPED : \"$USER_HOME/.ssh/id_rsa\" exists"
        return 0
    fi
    echo -n $PASS | sudo -S  su - $USER -c "ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ''" 
}


# copy-ssh
copy-ssh() {
    echo "TARGET_HOSTS = $TARGET_HOSTS"
    for host in ${TARGET_HOSTS}; do
        echo "Start ssh-copy-id at [$host] "
        echo -n $PASS | sudo -S  su - $USER -c "sshpass -p $PASS ssh-copy-id -o StrictHostKeyChecking=no $USER@$host"
        echo "Finished ssh-copy-id at [$host] "
    done
}

# start script
initialize_args $*
# echo "target_user=[$USER]"
# echo "target_pass=[$PASS]"
# echo "TARGET_HOSTS=[$TARGET_HOSTS]"
echo "========== generate ssh key [$USER] =========="
generate_ssh_key
echo "========== copy ssh key to [$TARGET_HOSTS] =========="
copy-ssh
