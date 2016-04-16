#!/bin/bash

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

function func_usage(){
    echo "$SCRIPT_NAME <AWS_INSTANCE>"
    exit
}

ANSIBLE_USER=ec2-user
REMOTE_SCRIPT_HOME=/opt
PRV_KEY=jongseokChoi.pem
AWS_INSTANCE=$1

# $1: script
function func_run_script_from_remote(){
    local script=$1

    tool_ansible_copy_and_run_script_in_sudo $ANSIBLE_USER $SCRIPT_DIR/$script $REMOTE_SCRIPT_HOME/$script $ANSIBLE_USER $PRV_KEY $AWS_INSTANCE
    
}


# install git
echo "ec2=$AWS_INSTANCE"
func_run_script_from_remote install_git.sh
