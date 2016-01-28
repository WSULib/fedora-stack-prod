#!/bin/sh
echo "---- Cleanup ------------------------------------------------"

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

# copy apache / info file
cp $SHARED_DIR/config/cleanup/index.php /var/www/wsuls/

# # eulxml
# cd /tmp
# cp $SHARED_DIR/downloads/cleanup/eulxml-0.22.1.tar.gz /tmp
# tar -xvf eulxml-0.22.1.tar.gz
# cd eulxml-0.22.1
# python setup.py install
# # remove bad requests from eulxml install
# rm -r /usr/lib/python2.7/dist-packages/requests*

# python progressbar for repo-cp
pip install progressbar