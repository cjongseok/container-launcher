#!/bin/bash
set -u

if [ -z $1 ] || [ -z "$2" ]; then
    echo "$0 <HBASE_SERVICE_NAME> <HDFS_NAMENODE> <ZK_QUORUM> <REGIONSERVERS> <BACKUP_MASTERS>"
    exit
fi

SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

readonly HBASE_DOCKER_GIT_URL=https://github.com/cjongseok/hbase.git
readonly HBASE_DOCKER_GIT_BRANCH=1.2.1
readonly HBASE_DOCKER_HOME=/opt/hbase
readonly DOCKER_COMPOSE_HBASE_MASTER=$HBASE_DOCKER_HOME/master/docker-compose.yml
readonly DOCKER_COMPOSE_HBASE_BACKUP_MASTER=$HBASE_DOCKER_HOME/backup-master/docker-compose.yml
readonly DOCKER_COMPOSE_HBASE_REGIONSERVER=$HBASE_DOCKER_HOME/regionserver/docker-compose.yml

# Hbase Environment ########################################################
readonly HBASE_SERVICE_NAME="$1"
readonly HDFS_NAMENODE="$2"
readonly ZK_QUORUM="$(echo "$3" | sed 's/ /,/g')" # change space separated value into csv
#readonly REGIONSERVERS="$4"
#readonly BACKUP_MASTERS="$5"

############################################################################

hbase_compose_files=( "$DOCKER_COMPOSE_HBASE_MASTER" "$DOCKER_COMPOSE_HBASE_BACKUP_MASTER" "$DOCKER_COMPOSE_HBASE_REGIONSERVER" )

function func_configure_docker_compose(){

    local index=0
    local size=${#hbase_compose_files[@]}
    for ((; index<size; index++)); do
        local compose_file=${hbase_compose_files[index]}
        #echo "configure $compose_file with $HBASE_SERVICE_NAME $HDFS_NAMENODE $ZK_QUORUM $REGIONSERVERS $BACKUP_MASTERS"
        echo "configure $compose_file with $HBASE_SERVICE_NAME $HDFS_NAMENODE $ZK_QUORUM"

        # Configure env vars
        tool_update_env_var_in_docker_compose "SERVICE_NAME" "$HBASE_SERVICE_NAME" $compose_file
        tool_update_env_var_in_docker_compose "HDFS_NAMENODE" "$HDFS_NAMENODE" $compose_file
        tool_update_env_var_in_docker_compose "ZK_QUORUM" "$ZK_QUORUM" $compose_file
#        tool_update_env_var_in_docker_compose "REGIONSERVERS" "$REGIONSERVERS" $compose_file
#        tool_update_env_var_in_docker_compose "BACKUP_MASTERS" "$BACKUP_MASTERS" $compose_file

        # Configure properties
        tool_template_fill_in_in_place $compose_file "HOST_NAME" $(hostname)
    done
}

tool_git_clone $HBASE_DOCKER_GIT_URL $HBASE_DOCKER_HOME $HBASE_DOCKER_GIT_BRANCH
func_configure_docker_compose
