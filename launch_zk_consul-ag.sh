#!/bin/bash
set -u


SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

function func_usage(){
    echo "$SCRIPT_NAME <ZK_SERVICE_NAME> <ZK_SERVERS>"    
#    echo "$SCRIPT_NAME -a <ZK_SERVICE_NAME> <ZK_SERVERS>"    
#    echo "$SCRIPT_NAME -j <ARG_JSON_FILE>"
#    echo "$SCRIPT_NAME <JSON_SRING>"
    exit
}


# Setup env 
. ${SCRIPT_DIR}/docker_env.sh
. ${SCRIPT_DIR}/consul_env.sh
. ${SCRIPT_DIR}/zk_env.sh zks1 "zks1"

ENV_FILES=( "${SCRIPT_DIR}/docker_env.sh" "${SCRIPT_DIR}/consul_env.sh" "${SCRIPT_DIR}/zk_env.sh zks1")
DOCKER_COMPOSE_FILES=( "${DOCKER_COMPOSE_AWS_AGENT}" "${DOCKER_COMPOSE_ZK_SERVER}")

# Launch containers
for ((index=0; index<${#DOCKER_COMPOSE_FILES[@]}; index++)); do
    tool_docker_compose_up ${DOCKER_COMPOSE_FILES[index]}
done


