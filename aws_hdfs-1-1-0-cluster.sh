#!/bin/bash

# $1 json file
#
# 1-1-0 means 1 namenode, 1 secondary namenode, and 0 datanode cluster
#

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

EC2_USER_NAME=ec2-user
EC2_PRV_KEY=jongseokChoi.pem
EC2_ENV=$SCRIPT_DIR/ec2_env.sh

LAUNCHER_NN=launch_hdfs-nn_consul-ag.sh
LAUNCHER_NN2=launch_hdfs-2nd-nn_consul-ag.sh

### Bring Your Own Launcher HERE ##################################################
LAUNCHER_GIT_REPO=https://github.com/cjongseok/container-launcher.git
LAUNCHER_GIT_DEST=/opt/launcher
LAUNCHER_GIT_VERSION=master

##################################################################################


function func_usage(){
    echo "$SCRIPT_NAME <ARG_JSON_FILE>"
    exit
}

# parse json file
#if [ ! $# -eq 1 ]; then
#    func_usage
#fi
json_file=$1
json_obj=$(tool_json_get_obj $json_file)


# check instance availability
    # ec2-dns is not specified -> launch a new instance -> for now, throw error
    # never launched -> throw error
    # stopped -> start the instance
    # running -> run containers on the instance

#function func_check_instances(){

    # availability
   
    # ports
#}

# $1: instance public-dnses
function func_launch(){

    # for each instance
    # deliver and run script in background
    # save logs on local
    # join all the instances

    local primary_obj=$(tool_json_get_obj_value "$json_obj" "primary")
    local primary_ec2_dns=$(tool_json_get_obj_value "$primary_obj" "ec2_dns")
    local primary_args=$(tool_json_get_obj_value "$primary_obj" "args.hdfs")
    local primary_srv_name=$(tool_json_get_obj_value "$primary_args" "HDFS_SERVICE_NAME")
    local primary_nn=$(tool_json_get_obj_value "$primary_args" "HDFS_NAMENODE")
    local primary_nn2=$(tool_json_get_obj_value "$primary_args" "HDFS_SECONDARY_NAMENODE")
    local primary_cmd_args="$LAUNCHER_GIT_DEST/$LAUNCHER_NN $primary_srv_name $primary_nn $primary_nn2"

    local secondary_obj=$(tool_json_get_obj_value "$json_obj" "secondary")
    local secondary_ec2_dns=$(tool_json_get_obj_value "$secondary_obj" "ec2_dns")
    local secondary_args=$(tool_json_get_obj_value "$secondary_obj" "args.hdfs")
    local secondary_srv_name=$(tool_json_get_obj_value "$secondary_args" "HDFS_SERVICE_NAME")
    local secondary_nn=$(tool_json_get_obj_value "$secondary_args" "HDFS_NAMENODE")
    local secondary_nn2=$(tool_json_get_obj_value "$secondary_args" "HDFS_SECONDARY_NAMENODE")
    local secondary_cmd_args="$LAUNCHER_GIT_DEST/$LAUNCHER_NN2 $secondary_srv_name $secondary_nn $secondary_nn2"

    # Launch primary namenode
    $EC2_ENV $primary_ec2_dns
    tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$cmd_args" $primary_ec2_dns

    # Launch secondary namenode
    $EC2_ENV $secondary_ec2_dns
    tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$cmd_args" $secondary_ec2_dns
}

# validate json file 

func_launch
