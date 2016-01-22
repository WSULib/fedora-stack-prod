#!/bin/sh
echo "---- Bootstrapping ------------------------------------------------"

#### GET ENVARS #################################################
SHARED_DIR=$1

if [ -f "$SHARED_DIR/config/envvars" ]; then
  . $SHARED_DIR/config/envvars
  printf "found your local envvars file. Using it."

else
  . $SHARED_DIR/config/envvars.default
  printf "found your default envvars file. Using its default values."

fi
#################################################################

# Update
apt-get -y update && apt-get -y upgrade

# SSH
apt-get -y install openssh-server

# Build tools
apt-get -y install build-essential

# Python essentials
apt-get -y install libxml2-dev libxslt1-dev python-dev python-setuptools

# Git vim
apt-get -y install git vim

# Wget and curl
apt-get -y install wget curl

# FFmpeg
sudo add-apt-repository -y ppa:mc3man/trusty-media
sudo apt-get -y update
sudo apt-get -y install ffmpeg

# visualization tools
apt-get -y install htop tree ncdu

# setup tailing
apt-get -y install multitail
echo "multitail /var/log/tomcat7/catalina.out /var/log/apache2/silo_access.log /var/log/ouroboros.err.log /var/log/celery.err.log /opt/fedora/server/logs/fedora.log" > /usr/bin/alltails
chmod +x /usr/bin/alltails

# Create Users
useradd -m -s /bin/bash loris
echo loris:password | chpasswd
