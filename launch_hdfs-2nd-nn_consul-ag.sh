#!/bin/bash
set -u

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

function func_usage(){
    echo "$SCRIPT_NAME <HDFS_SRV_NAME> <PRIMARY_NAMENODE_SRV_NAME>"    
    exit
}

HDFS_SRV_NAME="$1"
PRIMARY_NAMENODE_SRV_NAME="$2"
#SECONDARY_NAMENODE_SRV_NAME=localhost
SECONDARY_NAMENODE_SRV_NAME=$HDFS_SRV_NAME

# Setup env 
. ${SCRIPT_DIR}/docker_env.sh
. ${SCRIPT_DIR}/consul_env.sh
. ${SCRIPT_DIR}/hdfs_env.sh "$HDFS_SRV_NAME" "$PRIMARY_NAMENODE_SRV_NAME" "$SECONDARY_NAMENODE_SRV_NAME"

DOCKER_COMPOSE_FILES=( "${DOCKER_COMPOSE_CONSUL_AGENT}" "${DOCKER_COMPOSE_HDFS_2ND_NAMENODE}" )

# Launch containers
for ((index=0; index<${#DOCKER_COMPOSE_FILES[@]}; index++)); do
    tool_up_docker_compose ${DOCKER_COMPOSE_FILES[index]}
done


