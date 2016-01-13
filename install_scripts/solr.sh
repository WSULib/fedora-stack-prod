
echo "--------------- Installing Solr 4.1 ------------------------------"

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

printf "Downloading Solr"
wget "http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz"

cd /tmp
cp $SHARED_DIR/downloads/solr-$SOLR_VERSION.tgz /tmp
echo "Extracting Solr"
tar -xzf solr-"$SOLR_VERSION".tgz
cp -v /tmp/solr-"$SOLR_VERSION"/dist/solr-"$SOLR_VERSION".war /var/lib/tomcat7/webapps/solr4.war
service tomcat7 restart

# Waiting for Solr war file to initialize and create the solr4 directory
while [ ! -d /var/lib/tomcat7/webapps/solr4/WEB-INF/ ]
do
 echo "waiting for Solr to deploy..."
 sleep 2
done

chown -hR tomcat7:tomcat7 /usr/share/tomcat7/lib

cp $SHARED_DIR/downloads/solr/$SOLR_CATALINA_CONFIG /etc/tomcat7/Catalina/localhost/solr4.xml

chown -hR root:tomcat7 /etc/tomcat7/Catalina/localhost

cp -r $SHARED_DIR/config/solr/multicore/ $SOLR_HOME/

cp -r $SHARED_DIR/config/solr/lib/ $SOLR_HOME/

chown -hR tomcat7:tomcat7 $SOLR_HOME

service tomcat7 restart
