#!/bin/sh
echo "---- Installing Ouroboros ------------------------------------------------"

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

if [ ! -d $OUROBOROS_HOME ]; then
  mkdir $OUROBOROS_HOME
fi

# change to dir
cd /opt

# clone repository
git clone https://github.com/WSUlib/ouroboros.git
cd ouroboros

# copy php script for supporting Datatables
cp $SHARED_DIR/downloads/ouroboros/*.php /usr/lib/cgi-bin
chown -R www-data:www-data /usr/lib/cgi-bin

# install system dependencies
apt-get -y install libxml2-dev libxslt1-dev python-dev python-pip python-mysqldb python-lxml libldap2-dev libsasl2-dev libjpeg-dev pdftk imagemagick

# python modules
pip install -r requirements.txt

# other applications
# redis
apt-get -y install redis-server

# copy ouroboros's localConfig and replace host info
cp $SHARED_DIR/downloads/ouroboros/localConfig.py /opt/ouroboros/localConfig.py
sed -i "s/APP_HOST_PLACEHOLDER/$VM_HOST/g" /opt/ouroboros/localConfig.py

# create MySQL database, users, tables, then populate
echo "creating MySQL database, users, and tables"
mysql --user=root --password=$SQL_PASSWORD < $SHARED_DIR/downloads/ouroboros/ouroboros_mysql_db_create.sql
ipython <<EOF
from console import *
db.create_all()
EOF
mysql --user=root --password=$SQL_PASSWORD < $SHARED_DIR/downloads/ouroboros/ouroboros_mysql_db_populate.sql

# scaffold (NEEDS ATTEBNTION)
mkdir /tmp/Ouroboros
mkdir /tmp/Ouroboros/ingest_workspace
mkdir /var/www/wsuls/Ouroboros
mkdir /var/www/wsuls/Ouroboros/export/

# copy Ouroboros and Celery conf to supervisor dir, reread, update (automatically starts then)
cp $SHARED_DIR/config/ouroboros/ouroboros.conf /etc/supervisor/conf.d/
cp $SHARED_DIR/config/ouroboros/celery.conf /etc/supervisor/conf.d/
supervisorctl reread
supervisorctl update

# overwrite pip installed eulfedora with WSU fork
cd /opt
git clone https://github.com/WSULib/eulfedora.git
cd eulfedora
# building and installing from 'master' branch for stability
git checkout master
python setup.py install
chown -R vagrant /opt/eulfedora

######### Extra Dependencies ##########################
# dependencies for pillow
sudo apt-get -y install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
# reinstall pillow
sudo pip install --upgrade pillow




