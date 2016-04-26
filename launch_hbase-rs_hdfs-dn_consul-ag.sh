#!/bin/bash
set -u

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

function func_usage(){
    #echo "$SCRIPT_NAME <SERVICE_NAME> <HDFS_NAMENODE> <HDFS_2ND_NAMENODE> <ZK_QUORUM> <REGIONSERVERS> <BACKUP_MASTERS>"
    echo "$SCRIPT_NAME <SERVICE_NAME> <HDFS_NAMENODE> <HDFS_2ND_NAMENODE> <ZK_QUORUM>"
    exit
}

readonly HDFS_SERVICE_NAME=hdfs_dn
readonly HBASE_SERVICE_NAME="$1"
readonly HDFS_NAMENODE="$2"
readonly HDFS_SECONDARY_NAMENODE="$3"
readonly ZK_QUORUM="$4"
#readonly REGIONSERVERS="$5"
#readonly BACKUP_MASTERS="$6"

# Setup env
. ${SCRIPT_DIR}/docker_env.sh
. ${SCRIPT_DIR}/consul_env.sh
. ${SCRIPT_DIR}/hdfs_env.sh "$HDFS_SERVICE_NAME" "$HDFS_NAMENODE" "$HDFS_SECONDARY_NAMENODE"
. ${SCRIPT_DIR}/hbase_env.sh "$HBASE_SERVICE_NAME" "$HDFS_NAMENODE" "$ZK_QUORUM"

DOCKER_COMPOSE_FILES=( "${DOCKER_COMPOSE_CONSUL_AGENT}" "${DOCKER_COMPOSE_HDFS_DATANODE}" "${DOCKER_COMPOSE_HBASE_MASTER}" )

# Launch containers
for ((index=0; index<${#DOCKER_COMPOSE_FILES[@]}; index++)); do
    tool_up_docker_compose ${DOCKER_COMPOSE_FILES[index]}
done

