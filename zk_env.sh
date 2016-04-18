#!/bin/bash
set -u

# $1: ZooKeeper server service name

if [ -z $1 ] || [ -z "$2" ]; then
    echo "zk_env.sh <SERVICE_NAME> <SERVERS> [MYID]"
    exit
fi

SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

# ZooKeeper Environment ############################################################################
#  Consul Service Name
readonly SERVICE_NAME="$1"
readonly ZK_SERVERS="$2"
readonly ZK_MYID="$3"

echo "SERVICE_NAME=$SERVICE_NAME"
echo "ZK_SERVERS=$ZK_SERVERS"
echo "ZK_MYID=$ZK_MYID"
#  And something

#################################################################################################


readonly ZK_DOCKER_GIT_URL=https://github.com/cjongseok/zookeeper.git
readonly ZK_DOCKER_GIT_BRANCH=3.4.6

readonly ZK_DOCKER_HOME=/opt/zookeeper
readonly DOCKER_COMPOSE_ZK_SERVER=$ZK_DOCKER_HOME/docker-compose.yml

#compose_files=( "$DOCKER_COMPOSE_AWS_AGENT" "$DOCKER_COMPOSE_AWS_SERVER_BOOTSTRAPPER" )


function func_configure_docker_compose(){

    # Configure SERVICE_NAME
    tool_update_env_var_in_docker_compose "SERVICE_NAME" $SERVICE_NAME $DOCKER_COMPOSE_ZK_SERVER

    # Configure ZK_SERVERS
    tool_update_env_var_in_docker_compose "ZK_SERVERS" "$ZK_SERVERS" $DOCKER_COMPOSE_ZK_SERVER

    # Configure ZK_MYID
    tool_update_env_var_in_docker_compose "ZK_MYID" "$ZK_MYID" $DOCKER_COMPOSE_ZK_SERVER

    # Configure something here
}

tool_git_clone $ZK_DOCKER_GIT_URL $ZK_DOCKER_HOME $ZK_DOCKER_GIT_BRANCH
func_configure_docker_compose
