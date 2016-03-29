#!/bin/bash
echo "---- Installing Fedora Commons 3.x ------------------------------------------------"

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

# Downloads (currently in downloads dir for dev)
# 3.8
FEDORA_3_8="http://sourceforge.net/projects/fedora-commons/files/fedora/3.8.1/fcrepo-installer-3.8.1.jar/download"

# 3.6.2
FEDORA_3_6="http://sourceforge.net/projects/fedora-commons/files/fedora/3.6.2/fcrepo-installer-3.6.2.jar/download"

# Create MySQL DB
mysql --user=root --password=$SQL_PASSWORD < $SHARED_DIR/downloads/fedora/fedora_mysql_db_create.sql

# Create MySQL DB
cp $SHARED_DIR/downloads/fedora/fedora_mysql_db_create.sql /tmp/fedora_mysql_db_create.sql
sed -i "s/FEDORA_MYSQL_USERNAME/$FEDORA_MYSQL_USERNAME/g" /tmp/fedora_mysql_db_create.sql
sed -i "s/FEDORA_MYSQL_PASSWORD/$FEDORA_MYSQL_PASSWORD/g" /tmp/fedora_mysql_db_create.sql
mysql --user=root --password=$SQL_PASSWORD < /tmp/fedora_mysql_db_create.sql

# Installation (copy and sed in the install.properties)
cp $SHARED_DIR/downloads/fedora/install.properties /tmp/install.properties
sed -i "s/FEDORA_ADMIN_USERNAME/$FEDORA_ADMIN_USERNAME/g" /tmp/install.properties
sed -i "s/FEDORA_ADMIN_PASSWORD/$FEDORA_ADMIN_PASSWORD/g" /tmp/install.properties
sed -i "s/FEDORA_MYSQL_USERNAME/$FEDORA_MYSQL_USERNAME/g" /tmp/install.properties
sed -i "s/FEDORA_MYSQL_PASSWORD/$FEDORA_MYSQL_PASSWORD/g" /tmp/install.properties
java -jar $SHARED_DIR/downloads/fedora/fcrepo-installer-3.8.1.jar /tmp/install.properties

# copy custom fedora.fcfg and replace values
cp /opt/fedora/server/config/fedora.fcfg /opt/fedora/server/config/fedora.fcfg.BACKUP
cp $SHARED_DIR/downloads/fedora/fedora.fcfg /opt/fedora/server/config
sed -i "s/FEDORA_ADMIN_USERNAME/$FEDORA_ADMIN_USERNAME/g" /opt/fedora/server/config/fedora.fcfg
sed -i "s/FEDORA_ADMIN_PASSWORD/$FEDORA_ADMIN_PASSWORD/g" /opt/fedora/server/config/fedora.fcfg
sed -i "s/FEDORA_MYSQL_USERNAME/$FEDORA_MYSQL_USERNAME/g" /opt/fedora/server/config/fedora.fcfg
sed -i "s/FEDORA_MYSQL_PASSWORD/$FEDORA_MYSQL_PASSWORD/g" /opt/fedora/server/config/fedora.fcfg
sed -i "s/FEDORA_SERVER_HOST/$VM_HOST/g" /opt/fedora/server/config/fedora.fcfg

# chown fedora dir
chown -R tomcat7:tomcat7 /opt/fedora

# restart tomcat7
service tomcat7 restart

# Waiting for fedora to form
while [ ! -d /opt/fedora/data/fedora-xacml-policies/repository-policies ]
do
 echo "waiting for fedora repository policies directory..."
 tree /opt/fedora/data/fedora-xacml-policies/
 sleep 2
done

# copy XACML policies
echo "copying XACML policies to /data directory"
mkdir /opt/fedora/data/fedora-xacml-policies/repository-policies/WSU
cp $SHARED_DIR/downloads/WSUDOR_infrastructure/XACML/*.xml /opt/fedora/data/fedora-xacml-policies/repository-policies/WSU/

# chown fedora dir (after copying policies)
chown -R tomcat7:tomcat7 /opt/fedora

# restart tomcat7
service tomcat7 restart

# ingest infrastructure objects
# fedora-ingest f obj1.xml info:fedora/fedora-system:FOXML-1.1 myrepo.com:8443 jane jpw https
echo "ingesting infrastructural objects to Fedora"
export FEDORA_HOME=/opt/fedora

# First Ingest - Essential Objects
FILES=$SHARED_DIR/downloads/WSUDOR_infrastructure/fedora_objects/first_ingest/*.xml
for f in $FILES
do
  echo "Ingesting $f..."
  # take action on each file. $f store current file name
  CMD="/opt/fedora/client/bin/fedora-ingest.sh f $f info:fedora/fedora-system:FOXML-1.1 localhost:8080 $FEDORA_ADMIN_USERNAME $FEDORA_ADMIN_PASSWORD http"
  echo $CMD
  $CMD
done

# Secondary Ingest - Objects dependent on Primary Objects
FILES=$SHARED_DIR/downloads/WSUDOR_infrastructure/fedora_objects/second_ingest/*.xml
for f in $FILES
do
  echo "Ingesting $f..."
  # take action on each file. $f store current file name
  CMD="/opt/fedora/client/bin/fedora-ingest.sh f $f info:fedora/fedora-system:FOXML-1.1 localhost:8080 $FEDORA_ADMIN_USERNAME $FEDORA_ADMIN_PASSWORD http"
  echo $CMD
  $CMD
done
