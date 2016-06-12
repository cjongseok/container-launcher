#!/bin/bash

SCRIPT_NAME=$0
SCRIPT_DIR=$(dirname $(readlink -e $0))

LINUX_TYPE="$(cat /etc/os-release | grep "ID_LIKE" | sed -e 's/ID_LIKE=\(.*\)/\1/g' -e 's/"//g')"

bin=git
pkg=git

# Install Git
unset is_bin_exists
if [ ! -z $(which $bin) ]; then
    is_bin_exists="$(which $bin)"

elif [ ! -z $(which /usr/local/bin/$bin) ]; then
    is_bin_exists="/usr/local/bin/$bin"
fi  


if [ -z $is_bin_exists ]; then
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

# Set hostname
#sudo hostname $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo hostname $(curl -s http://169.254.169.254/latest/meta-data/hostname)
