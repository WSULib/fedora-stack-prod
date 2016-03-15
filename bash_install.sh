#!/bin/bash

# CHECK USER #
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#### GET ENVARS #################################################
# make a symbolic link from current directory to /vagrant
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sudo ln -s $DIR /vagrant
set -- /vagrant
SHARED_DIR=$1

printf $SHARED_DIR
if [ -f "$SHARED_DIR/config/envvars" ]; then
  . $SHARED_DIR/config/envvars
  printf "found your local envvars file. Using it."

else
  . $SHARED_DIR/config/envvars.default
  printf "found your default envvars file. Using its default values."

fi
#################################################################

# Setup before provisioning
sudo apt-get -y install sshfs

# Mount downloads folder for provisioners
sshfs -o idmap=user -o follow_symlinks -o nonempty vagrantworker@141.217.54.96:/home/vagrantworker/vms/fedora-stack-prod/downloads/ /vagrant/downloads/

# Run provisioners
source $DIR/install_scripts/bootstrap.sh
source $DIR/install_scripts/lamp.sh
source $DIR/install_scripts/java.sh
source $DIR/install_scripts/tomcat.sh
source $DIR/install_scripts/solr.sh
source $DIR/install_scripts/fedora.sh
source $DIR/install_scripts/oaiprovider.sh
source $DIR/install_scripts/supervisor.sh
source $DIR/install_scripts/kakadu.sh
source $DIR/install_scripts/ouroboros.sh
source $DIR/install_scripts/front_end.sh
source $DIR/install_scripts/loris.sh
source $DIR/install_scripts/utilities.sh
source $DIR/install_scripts/cleanup.sh


# unmount sshfs dir
fusermount -u $DIR/downloads
# remove symlink
sudo unlink /vagrant

printf "DONE!"
