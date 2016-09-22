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

# install ruby requirements
apt-get -y install python-software-properties
apt-add-repository -y ppa:brightbox/ruby-ng
apt-get -y update
apt-get -y install ruby2.2 ruby-switch
ruby-switch --set ruby2.2
apt-get -y install ruby2.2-dev

# install teifacsimile_to_jekyll gem
# https://github.com/emory-libraries-ecds/teifacsimile-to-jekyll
gem install $SHARED_DIR/downloads/readux/teifacsimile_to_jekyll-0.6.0.gem

# clone readux repository
cd /opt
git clone https://github.com/WSULib/readux.git
cd readux
git checkout wsu_deploy

# use ouroboros venv
workon ouroboros

# from deployment notes: http://readux.readthedocs.io/en/develop/deploynotes.html
pip install fabric
fab build

# copy config and replace values
cp $SHARED_DIR/downloads/readux/localsettings.py /opt/readux/readux/localsettings.py
cp $SHARED_DIR/downloads/readux/settings.py /opt/readux/readux/settings.py
# replace these
# FEDORA_USER, FEDORA_ADMIN_PASSWORD, VM_HOST
sed -i "s/FEDORA_ADMIN_USERNAME/$FEDORA_ADMIN_USERNAME/g" /opt/readux/readux/localsettings.py
sed -i "s/FEDORA_ADMIN_PASSWORD/$FEDORA_ADMIN_PASSWORD/g" /opt/readux/readux/localsettings.py
sed -i "s/VM_HOST/$VM_HOST/g" /opt/readux/readux/localsettings.py

# update db
python manage.py syncdb
python manage.py migrate

# install WSUDOR fork / copy of Emory's eultheme for local editing
cd /opt
git clone https://github.com/WSULib/wsudor_django_theme
cd wsudor_django_theme
pip install --upgrade .

# collect static files
cd /opt/readux
python manage.py collectstatic --noinput

# chown
chown -R ouroboros:admin /opt/readux
chown -R ouroboros:admin /opt/wsudor_django_theme

# restart apache
service apache2 restart

# close
deactivate
echo "deactivating virtualenv"
