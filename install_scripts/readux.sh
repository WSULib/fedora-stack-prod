#!/bin/bash
echo "---- Installing Readux ------------------------------------------------"

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

# clone readux repository
cd /opt
git clone https://github.com/WSULib/readux.git
cd readux

# use ouroboros venv
workon ouroboros

# install 
python setup.py install

# copy config, and update hosts
cp $SHARED_DIR/downloads/readux/localsettings.py /opt/readux/readux/localsettings.py

# install WSUDOR fork / copy of Emory's eultheme
cd /opt
git clone https://github.com/WSULib/wsudor_django_theme
cd wsudor_django_theme
python setup.py install

# chown
chown -R ouroboros:admin /opt/readux
chown -R ouroboros:admin /opt/wsudor_django_theme

# close
deactivate
echo "deactivating virtualenv"
