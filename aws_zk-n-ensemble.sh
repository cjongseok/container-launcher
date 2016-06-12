#!/bin/bash

# $1 json file

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

#JSON_KEY_EC2_DNS="ec2_dns"
#JSON_KEY_ZK_SERVICE_NAME="ZK_SERVICE_NAME"
#JSON_KEY_ZK_SERVERS="ZK_SERVERS"

EC2_USER_NAME=ec2-user
EC2_PRV_KEY=jongseokChoi.pem
ZK_LAUNCHER=launch_zk_consul-ag.sh

### Bring Your Own Launcher HERE ##################################################
LAUNCHER_GIT_REPO=https://github.com/cjongseok/container-launcher.git
LAUNCHER_GIT_DEST=/opt/launcher
LAUNCHER_GIT_VERSION=master

##################################################################################



function func_usage(){
    echo "$SCRIPT_NAME <ARG_JSON_FILE> <HOST> ..."
    exit
}

# parse json file
#if [ ! $# -eq 1 ]; then
#    func_usage
#fi
json_file=$1
json_objs=$(tool_json_get_obj $json_file)
json_obj_num=$(tool_json_array_length "$json_objs")



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
    #for ((index=0; index<json_obj_num; index++)); do
    local unset index
    local arr_len=$(tool_json_array_length "$json_objs")
    for ((index=0; index<arr_len; index++)); do
        echo "index=$index"
        local json_obj=$(tool_json_array_index_of "$json_objs" $index)
        local ec2_dns=$(tool_json_get_obj_value "$json_obj" "ec2_dns")
        local zk_args=$(tool_json_get_obj_value "$json_obj" "args.zookeeper")
        local zk_srv_name=$(tool_json_get_obj_value "$zk_args" "ZK_SERVICE_NAME")
        local zk_servers=$(tool_json_get_obj_value "$zk_args" "ZK_SERVERS")
        local zk_myid=$(tool_json_get_obj_value "$zk_args" "ZK_MYID")
        local cmd_args="$LAUNCHER_GIT_DEST/$ZK_LAUNCHER $zk_srv_name $zk_servers $zk_myid"
        #local cmd_args="$LAUNCHER_GIT_DEST/$ZK_LAUNCHER"

        # Setup ec2 env
        $SCRIPT_DIR/ec2_env.sh $ec2_dns

        # Launch the zk_launcher on the instance
        tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$cmd_args" $ec2_dns

        #echo "$ec2_dns  $zk_srv_name $zk_servers"
    done
}

# validate json file 

func_launch
