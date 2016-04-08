#!/bin/bash
set -u
LINUX_TYPE=$(cat /etc/os-release | grep "ID_LIKE" | sed 's/ID_LIKE=.*"\(.*\)"/\1/g')

function tool_run_as_root(){
    if [ "$EUID" -ne 0 ]; then
        echo "run as root"
        exit
    fi  
}

# $1: binary name
function tool_get_binary_path(){
    local bin_name=$1
    if [ ! -z $(which $bin_name) ]; then
        echo "$(which $bin_name)"

    elif [ ! -z $(which /usr/local/bin/$bin_name) ]; then
        echo "/usr/local/bin/$bin_name"
    fi
}

# $1 pkg name
function tool_install_pkg_if_not_exists(){
    local pkg=$1
    if [ -z $(tool_get_binary_path $pkg) ]; then
        case "$LINUX_TYPE" in
            "rhel fedora")
                #func_run_as_root
                sudo yum -y install $pkg 2>&1 > /dev/null
                ;;
            "debian")
                #func_run_as_root
                sudo apt-get -y install $pkg 2>&1 /dev/null
                ;;
            *)
                "$LINUX_TYPE is NOT supported"
                exit 1
                ;;
        esac
    fi
}

# $1 pip-pkg name
function tool_install_pip_pkg_if_not_exists(){
    pkg=$1
    if [ -z $(tool_get_binary_path $pkg) ]; then
        #func_run_as_root
        sudo pip install $pkg
    fi
}

# $1: git repository url
# $2: target directory to clone the repository
# $3: (Optional) brnach to checkout
function tool_git_clone(){
    local url=$1
    local target=$2
    local branch=$3

    if [ -z $url ]; then
        echo "No Git repository url provided"
        exit 1
    fi

    if [ -z $target ]; then
        echo "No target directory for Git clone is provided"
        exit 1
    fi

    tool_install_pkg_if_not_exists git

    git clone $url $target

    if [ ! -z $branch ]; then
        cd $target
        git checkout $branch
        cd -
    fi
}

# $1: env variable name
# $2: env variable value
# $3: docker-compose file path
function tool_update_env_var_in_docker_compose(){
    name=$1
    value=$2
    docker_compose=$3

    sed -i 's/^\( *- *'"$name"'\).*/\1='"$value"'/g' $docker_compose
}


# $1: Path of docker-compose.yml
function tool_docker_compose_up(){
    local docker_compose_file=$1
    echo "docker_compose_file=$docker_compose_file"
    local docker_compose_dir=$(dirname $docker_compose_file)

    if [ -z $docker_compose_file ]; then
        echo "No docker-compose file"
        exit
    fi

    tool_install_pip_pkg_if_not_exists docker-compose
    local DOCKER_COMPOSE=$(tool_get_binary_path docker-compose)
    echo "DOCKER_COMPOSE=$DOCKER_COMPOSE"
    cd $docker_compose_dir
    sudo $DOCKER_COMPOSE up -d
    cd -
}
