#!/bin/bash
set -u

readonly SCRIPT_DIR=$(dirname $(readlink -e $0))
. ${SCRIPT_DIR}/tools.sh

readonly DOCKER_BRIDGE_IP=$(ip addr show docker0 | awk '/inet / {print $2}' | cut -d/ -f1)
#DOCKER_BRIDGE_IP$(sudo docker network inspect bridge | jq '.[0].IPAM.Config[0].Gateway')
readonly DOCKER_HOST_DNS_SERVER=$(cat /etc/resolv.conf  | grep nameserver | head -1 | awk '{print $2}')

# Docker Daemon Environment #########################################################################
readonly HOST_NIC=eth0
readonly DOCKER_HOST_IP=$(ip addr show $HOST_NIC  | awk '/inet / {print $2}' | cut -d/ -f1)
readonly DOCKER_HOST_NAME=$(hostname)
readonly DOCKER_CONTAINER_1ST_DNS=$DOCKER_BRIDGE_IP
readonly DOCKER_CONTAINER_2ND_DNS=$DOCKER_HOST_DNS_SERVER
readonly DOCKER_CONTAINER_SEARCH_DOMAIN="service.consul"

##############################################################################################


# Consts and global variables
readonly SCRIPT_NAME=$0
readonly RHEL_DOCKER_CONF_FILE=/etc/sysconfig/docker
readonly DEBIAN_DOCKER_CONF_FILE=/etc/default/docker


function func_usage(){
    echo "$SCRIPT_NAME"
    echo ""
    echo "It defines env variables for Docker daemon woking "
    echo "with Consul"
    echo "For now, it only works on rhel fedora and debian "
    echo "Linux"
    exit
}


# It assumes OS is linux
#  $1: option
function func_write_option_to_docker_conf_file(){
    local option="$1"
    local unset option_var_name
    local unset docker_conf_file

    case "$LINUX_TYPE" in
        "rhel fedora")
            option_var_name="OPTIONS"
            docker_conf_file=$RHEL_DOCKER_CONF_FILE
            ;;
        "debian")
            option_var_name="DOCKER_OPTS"
            docker_conf_file=$DEBIAN_DOCKER_CONF_FILE
            ;;
        *)
            func_usage
            ;;
    esac

#    local predefined_option="$(cat $docker_conf_file | grep -E "^$option_var_name" | head -n 1 | sed 's/'"$option_var_name"'= *\"\(.*\)\"/\1/g')"
#    option="\"$option $predefined_option\""
#    if [ -z $(echo $predefined_option | awk '{print $1}') ]; then
#        echo "$option_var_name=$option" >> $docker_conf_file
#    else
#        sudo sed -i 's/^ *'"$option_var_name"'.*$/'"$option_var_name"'='"$option"'/g' $docker_conf_file
#    fi

    # TODO: If options already exists, do not apply it and restart docker

    option="\"$option\""
    sudo sed -i '/^'"$option_var_name"'/d' $docker_conf_file
    echo "$option_var_name=$option" >> $docker_conf_file


#    sed -i '/^OPTIONS.*$/d' $docker_conf_file
}

# Set Docker option
function func_apply_docker_option(){

    # Run docker daemon to get bridge ip
    sudo service docker start

    local option=""
    if [ ! -z $DOCKER_CONTAINER_1ST_DNS ]; then
        option="--dns $DOCKER_CONTAINER_1ST_DNS "
    fi

    if [ ! -z $DOCKER_CONTAINER_2ND_DNS ]; then
        option=$option"--dns $DOCKER_CONTAINER_2ND_DNS "
    fi

    if [ ! -z $DOCKER_CONTAINER_SEARCH_DOMAIN ]; then
        option=$option"--dns-search $DOCKER_CONTAINER_SEARCH_DOMAIN"
    fi

    # update docker conf file
    func_write_option_to_docker_conf_file "$option"

    # restart docker
    sudo service docker restart
    sleep 5
}

function func_install_docker_if_not_exists(){
    if [ -z $(which docker) ]; then
        local os_id=$(cat /etc/os-release | grep -E "^ID=" | sed 's/.*"\(.*\)"/\1/g')
        case "$os_id" in
            "amzn")
                tool_install_pkg_if_not_exists docker docker
                ;;
            *)
                echo "There is no Docker."
                echo "Please install Docker first."
                echo "Docker installation is not supported but AmazonLinux."
                ;;
        esac
    fi
}

tool_run_as_root
func_install_docker_if_not_exists
func_apply_docker_option
