#!/bin/bash

# $1 json file
#
# 1-n-m means 1 namenode, n secondary namenode, and m datanode cluster
#

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

EC2_USER_NAME=ec2-user
EC2_PRV_KEY=jongseokChoi.pem
EC2_ENV=$SCRIPT_DIR/ec2_env.sh


### Bring Your Own Launcher HERE ##################################################
LAUNCHER_GIT_REPO=https://github.com/cjongseok/container-launcher.git
LAUNCHER_GIT_DEST=/opt/launcher
LAUNCHER_GIT_VERSION=master

##################################################################################

LAUNCHER_MASTER=${LAUNCHER_GIT_DEST}/launch_hbase-m_consul-ag.sh
LAUNCHER_BACKUP_MASTER=${LAUNCHER_GIT_DEST}/launch_hbase-mb_consul-ag.sh
LAUNCHER_REGIONSERVER=${LAUNCHER_GIT_DEST}/launch_hbase-rs_hdfs-dn_consul-ag.sh


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
    local common_obj=$(tool_json_get_obj_value "$json_obj" "common")

    local hdfs_obj=$(tool_json_get_obj_value "$common_obj" "hdfs")
    local hdfs_namenode=$(tool_json_get_obj_value "$hdfs_obj" "HDFS_NAMENODE")
    local hdfs_2nd_namenode=$(tool_json_get_obj_value "$hdfs_obj" "HDFS_SECONDARY_NAMENODE")

    local hbase_obj=$(tool_json_get_obj_value "$common_obj" "hbase")
    local hbase_namenode=$(tool_json_get_obj_value "$hbase_obj" "HDFS_NAMENODE")
    local hbase_zk_quorum=$(tool_json_get_obj_value "$hbase_obj" "ZK_QUORUM")

    local master_obj=$(tool_json_get_obj_value "$json_obj" "master")
    local master_ec2_dns=$(tool_json_get_obj_value "$master_obj" "ec2_dns")
    local master_hbase=$(tool_json_get_obj_value "$master_obj" "hbase")
    local master_hbase_service_name=$(tool_json_get_obj_value "$master_hbase" "SERVICE_NAME")
    local master_cmd_line="$LAUNCHER_MASTER $master_hbase_service_name $hdfs_namenode $hbase_zk_quorum"

    local backup_master_objs=$(tool_json_get_obj_value "$json_obj" "backup_masters")

    local regionserver_objs=$(tool_json_get_obj_value "$json_obj" "regionservers")


    # Launch Hbase master
    $EC2_ENV $master_ec2_dns
    tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$master_cmd_line" $master_ec2_dns


    # Launch backup masters
    local unset index
    local arr_len=$(tool_json_array_length "$backup_master_objs")
    for ((index=0; index<arr_len; index++)); do
        local backup_master_obj=$(tool_json_array_index_of "$backup_master_objs" $index)
        local mb_ec2_dns=$(tool_json_get_obj_value "$backup_master_obj" "ec2_dns")
        local mb_hbase=$(tool_json_get_obj_value "$backup_master_obj" "hbase")
        local mb_hbase_service_name=$(tool_json_get_obj_value "$mb_hbase" "SERVICE_NAME")
        local mb_cmd_line="$LAUNCHER_BACKUP_MASTER $mb_hbase_service_name $hdfs_namenode $hbase_zk_quorum"

        $EC2_ENV $mb_ec2_dns
        tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$mb_cmd_line" $mb_ec2_dns
    done


    # Launch regionservers
    arr_len=$(tool_json_array_length "$regionserver_objs")
    for ((index=0; index<arr_len; index++)); do
        local regionserver_obj=$(tool_json_array_index_of "$regionserver_objs" $index)
        local rs_ec2_dns=$(tool_json_get_obj_value "$regionserver_obj" "ec2_dns")
        local rs_hbase=$(tool_json_get_obj_value "$regionserver_obj" "hbase")
        local rs_hbase_service_name=$(tool_json_get_obj_value "$rs_hbase" "SERVICE_NAME")
        local rs_cmd_line="$LAUNCHER_REGIONSERVER $rs_hbase_service_name $hdfs_namenode $hdfs_2nd_namenode $hbase_zk_quorum"

        $EC2_ENV $rs_ec2_dns
        tool_ansible_git_clone_and_run_in_sudo $EC2_USER_NAME $EC2_PRV_KEY $LAUNCHER_GIT_REPO $LAUNCHER_GIT_DEST $LAUNCHER_GIT_VERSION "$rs_cmd_line" $rs_ec2_dns
    done
}

# validate json file 

func_launch
