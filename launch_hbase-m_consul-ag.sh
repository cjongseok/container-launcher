#!/bin/bash
set -u

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

function func_usage(){
    #echo "$SCRIPT_NAME <SERVICE_NAME> <HDFS_NAMENODE> <ZK_QUORUM> <REGIONSERVERS> <BACKUP_MASTERS>"
    echo "$SCRIPT_NAME <SERVICE_NAME> <HDFS_NAMENODE> <ZK_QUORUM>"
    exit
}

readonly HBASE_SERVICE_NAME="$1"
readonly HDFS_NAMENODE="$2"
readonly ZK_QUORUM="$3"
#readonly REGIONSERVERS="$4"
#readonly BACKUP_MASTERS="$5"

# Setup env
. ${SCRIPT_DIR}/docker_env.sh
. ${SCRIPT_DIR}/consul_env.sh
. ${SCRIPT_DIR}/hbase_env.sh "$HBASE_SERVICE_NAME" "$HDFS_NAMENODE" "$ZK_QUORUM"
#. ${SCRIPT_DIR}/hbase_env.sh "$HBASE_SERVICE_NAME" "$HDFS_NAMENODE" "$ZK_QUORUM" "$REGIONSERVERS" "$BACKUP_MASTERS"

DOCKER_COMPOSE_FILES=( "${DOCKER_COMPOSE_CONSUL_AGENT}" "${DOCKER_COMPOSE_HBASE_MASTER}" )

# Launch containers
for ((index=0; index<${#DOCKER_COMPOSE_FILES[@]}; index++)); do
    tool_up_docker_compose ${DOCKER_COMPOSE_FILES[index]}
done

