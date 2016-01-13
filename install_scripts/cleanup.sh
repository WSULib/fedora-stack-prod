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

# ingest test bags
cd /opt/ouroboros/
cp $SHARED_DIR/downloads/ouroboros/ingest_bags.py /opt/ouroboros/
sudo python /opt/ouroboros/ingest_bags.py
sleep 15
curl http://localhost:5004/tasks/updateSolr/replicateStagingToProduction
sudo rm /opt/ouroboros/ingest_bags.py