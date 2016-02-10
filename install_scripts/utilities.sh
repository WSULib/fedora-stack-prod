
echo "--------------- Installing Utilities ------------------------------"

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

mkdir /opt/utilities

cd /opt/utilities
git clone https://github.com/WSULib/ichabod.git
git clone https://github.com/WSULib/POTDemailer.git
git clone https://github.com/WSULib/SWORD2DC.git
git clone https://github.com/WSULib/digital-collections-sitemaps.git
git clone https://github.com/WSULib/dc2Solr.git
git clone https://github.com/WSULib/dcArchive2Solr.git


# Write cronjobs
# crontab -l | { cat; echo "0 * * * * some_entry"; } | crontab -
crontab -l | { cat; echo "# Downloads item records from DC, indexes in Solr"; } | crontab -
crontab -l | { cat; echo "#0 23    * * *      cd /var/opt/solr_utilities/dc2Solr && python dc2Solr.py all >/dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "# Runs utility to harvest BioMed Central SWORD deposits in Fedora for ingest to Digital Commons"; } | crontab -
crontab -l | { cat; echo "#0 0    * * 1      python /var/opt/fedora_utilities/SWORD2DC/SWORD2DC.py >/dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "# Emails authors for DigitalCommons@WayneState's "Paper of the Day""; } | crontab -
crontab -l | { cat; echo "#0 12    * * *      cd /var/opt/digitalcommons_utilities/POTDemailer && python POTDemailer.py >/dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "# Runs script to update sitemaps for Google crawler"; } | crontab -
crontab -l | { cat; echo "#0 0    * * 0      cd /var/opt/solr_utilities/digital-collections-sitemaps && python digital-collections-sitemaps.py >/dev/null 2>&1"; } | crontab -
crontab -l | { cat; echo "# Runs ichabod page checker, hourly"; } | crontab -
crontab -l | { cat; echo "#0,30 * * * * cd /var/opt/digitalcollections_utilities/ichabod && python main.py check"; } | crontab -

# Install Dependencies
sudo pip install pyPdf

sudo cp $SHARED_DIR/downloads/utilities/apesmit-0.01.tar.gz /tmp/
tar -xvf apesmit-0.01.tar.gz
sudo python /tmp/apesmit-0.01/setup.py install
