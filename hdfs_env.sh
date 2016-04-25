#!/bin/bash
set -u

# $1: ZooKeeper server service name

if [ -z $1 ] || [ -z "$2" ]; then
    echo "$0 <HDFS_SERVICE_NAME> <HDFS_NAMENODE> <HDFS_SECONDARY_NAMENODE>"
    exit
fi

SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

readonly HADOOP_DOCKER_GIT_URL=https://github.com/cjongseok/hadoop.git
readonly HADOOP_DOCKER_GIT_BRANCH=2.4.1
readonly HADOOP_DOCKER_HOME=/opt/hadoop
readonly DOCKER_COMPOSE_HDFS_NAMENODE=$HADOOP_DOCKER_HOME/hdfs-namenode/docker-compose.yml
readonly DOCKER_COMPOSE_HDFS_2ND_NAMENODE=$HADOOP_DOCKER_HOME/hdfs-2ndnamenode/docker-compose.yml
readonly DOCKER_COMPOSE_HDFS_DATANODE=$HADOOP_DOCKER_HOME/hdfs-datanode/docker-compose.yml

# ZooKeeper Environment ############################################################################
#  Consul Service Name
readonly HDFS_SERVICE_NAME="$1"
readonly HDFS_NAMENODE="$2"
readonly HDFS_SECONDARY_NAMENODE="$3"
#readonly HDFS_HOSTNAME=$(hostname)
readonly HDFS_HOSTNAME="$HDFS_SERVICE_NAME"
readonly HDFS_DATA_VOLUME_HOST="/opt/hadoop/data"

#  And something

#################################################################################################


#compose_files=( "$DOCKER_COMPOSE_CONSUL_AGENT" "$DOCKER_COMPOSE_AWS_SERVER_BOOTSTRAPPER" )
hdfs_compose_files=( "$DOCKER_COMPOSE_HDFS_NAMENODE" "$DOCKER_COMPOSE_HDFS_2ND_NAMENODE" "$DOCKER_COMPOSE_HDFS_DATANODE")

function func_configure_docker_compose(){

    local index=0
    local size=${#hdfs_compose_files[@]}
    for ((; index<size; index++)); do
        local compose_file=${hdfs_compose_files[index]}
        echo "configure $compose_file with $HDFS_SERVICE_NAME $HDFS_NAMENODE $HDFS_SECONDARY_NAMENODE"

        # Configure env vars
        tool_update_env_var_in_docker_compose "SERVICE_NAME" $HDFS_SERVICE_NAME $compose_file
        tool_update_env_var_in_docker_compose "NAMENODE_SERVICE_NAME" $HDFS_NAMENODE $compose_file
        tool_update_env_var_in_docker_compose "SECONDARY_NAMENODE_SERVICE_NAME" $HDFS_SECONDARY_NAMENODE $compose_file
        
        # Configure properties
        tool_template_fill_in_in_place $compose_file "HDFS_DATA_VOLUME_HOST" $HDFS_DATA_VOLUME_HOST
        tool_template_fill_in_in_place $compose_file "HOST_NAME" $HDFS_HOSTNAME
    done
}

tool_git_clone $HADOOP_DOCKER_GIT_URL $HADOOP_DOCKER_HOME $HADOOP_DOCKER_GIT_BRANCH
func_configure_docker_compose
