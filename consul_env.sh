#!/bin/bash
set -u

readonly CONSUL_ENV_SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${CONSUL_ENV_SCRIPT_DIR}/tools.sh

# Consul Environment ############################################################################
#  Env variables to configure in docker-compose
DOCKER_HOST_DNS_SERVER=$(cat /etc/resolv.conf  | grep "nameserver" | head -1 | awk '{print $2 }')

#  And something

#################################################################################################


readonly CONSUL_DOCKER_GIT_URL=https://github.com/cjongseok/consul.git
readonly CONSUL_DOCKER_GIT_BRANCH=master

readonly CONSUL_DOCKER_HOME=/opt/consul
readonly DOCKER_COMPOSE_CONSUL_AGENT=$CONSUL_DOCKER_HOME/consul-agent-on-aws/docker-compose.yml
readonly DOCKER_COMPOSE_AWS_SERVER_BOOTSTRAPPER=$CONSUL_DOCKER_HOME/consul-server-bootstrap-on-aws/docker-compose.yml
#DOCKER_COMPOSE_SERVER_BOOTSTRAPPER=$CONSUL_HOME/consul-server-bootstrap/docker-compose.yml

#compose_files=( "$DOCKER_COMPOSE_CONSUL_AGENT" "$DOCKER_COMPOSE_AWS_SERVER_BOOTSTRAPPER" "$DOCKER_COMPOSE_SERVER_BOOTSTRAPPER" )
readonly compose_files=( "$DOCKER_COMPOSE_CONSUL_AGENT" "$DOCKER_COMPOSE_AWS_SERVER_BOOTSTRAPPER" )


function func_configure_docker_compose(){

    local index=0
    local size=${#compose_files[@]}
    for ((; index<size; index++)); do
        local compose_file=${compose_files[index]}

        # Configure DOCKER_HOST_DNS_SERVER
        tool_update_env_var_in_docker_compose "DOCKER_HOST_DNS_SERVER" $DOCKER_HOST_DNS_SERVER $compose_file 

        # Configure something here

        # Resolve <NODE_NAME>. DOCKER_HOST_NAME is defined by docker_env.sh
        tool_template_fill_in_in_place $compose_file "NODE_NAME" $DOCKER_HOST_NAME

        # Resolve <ADVERTISE_IP>. DOCKER_HOST_IP is defined by docker_env.sh
        tool_template_fill_in_in_place $compose_file "ADVERTISE_IP" $DOCKER_HOST_IP

    done
}


tool_git_clone $CONSUL_DOCKER_GIT_URL $CONSUL_DOCKER_HOME $CONSUL_DOCKER_GIT_BRANCH
func_configure_docker_compose
