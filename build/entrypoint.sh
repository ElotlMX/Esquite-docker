#!/bin/sh
LOGFILE="/data/app/esquite-init.log"
ESQUITE_DIR="/data/app/Esquite"
ESQUITE_DOCKER_DIR="/data/build"

##############################################################################  
logMsg()                                                                        
{                                                                               
    msg="[`date \"+%Y%m%d-%H:%M:%S\"`] $1"                                      
    echo $msg                                                                   
    echo $msg >> $LOGFILE                                                       
}                                                                               
##############################################################################  
execCmd()                                                                       
{                                                                               
    cmd="$1"                                                                    
    #logMsg "|-------- Executing: $1 ... "                                      
    #eval $cmd &>> $LOGFILE.exec                                                 
    eval $cmd 
    if [ $? -ne 0 ]; then                                                       
        logMsg "       ERROR: Execution of [$1]"                                
    else                                                                        
        logMsg "|----- OK ... $1"                                               
    fi                                                                          
}                                                                               
##############################################################################

logMsg "############################################################"
logMsg "########### Starting Esquite Docker container    ###########"

if [ ! -d "/data/app/" ]; then
    logMsg "Directory /data/app does not exist. Creating new directory ..."
    execCmd "sudo /bin/mkdir /data/app"
fi
envupdate=0
if [ ! -d "$ESQUITE_DIR/" ]; then
    logMsg "Copying Prebuilt Esquite Dir /home/elotl/Esquite/ to /data/app"
    execCmd "cp -rp /home/elotl/Esquite /data/app/"
    logMsg "Setting permissions of Esquite directory ..."
    execCmd "sudo /bin/chown -R elotl /data/*"
    logMsg "Preparing ENV file template ..."
    execCmd "cp $ESQUITE_DOCKER_DIR/esquite-env.yaml.template $ESQUITE_DIR/env.yaml"
    envupdate=1
fi

if [ ! -z "$CFG_CORPUS_ADMIN_ADMIN_PASS" ]; then
    logMsg "Setting new custom Corpus-admin password"
    echo -n "corpus-admin:" > /data/app/users.pwd; echo -n "$CFG_CORPUS_ADMIN_PASS" | mkpasswd -s -m sha-512 >> /data/app/users.pwd
else
    logMsg "Using default password for corpus-admin"
    echo -n "corpus-admin:" > /data/app/users.pwd; echo -n "elotl" | mkpasswd -s -m sha-512 >> /data/app/users.pwd
fi
if [ "$CFG_UPDATE_ON_BOOT" = "YES" ]; then
    logMsg "Update VAR enabled. Updating Esquite GIT repository ..."
    execCmd "cd $ESQUITE_DIR/"
    execCmd "git pull"
else
    logMsg "Skipping Update on BOOT. To update enable VAR CFG_UPDATE_ON_BOOT=YES ..."
fi
if [ ! -z "$CFG_INDEX" ]; then
    logMsg "Configuring VAR CFG_INDEX [$CFG_INDEX] ..."
    sed -i "s/INDEX:.*/INDEX: $CFG_INDEX/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut INDEX. Waiting 10 seconds for ELASTICSEARCH container ..."
    execCmd "sleep 10"
    elastic-test="`curl -X GET \"esquite-elasticsearch$:9200/esquite-production\"`"
    if [ -z "$elastic_test" ]; then
        logMsg "Default Index does not exist. Creating NEW index"
        execCmd "curl -X PUT -H \"Content-Type: application/json\" -d @$ESQUITE_DOCKER_DIR/esquite-elasticsearch.json.template esquite-elasticsearch:9200/esquite-production"
    else
        logMsg "Existing default index [esquite-production] exists."
    fi
fi
if [ ! -z "$CFG_L1" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_L1 [$CFG_L1] ..."
    sed -i "s/L1:.*/L1: $CFG_L1/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut L1 ..."
fi
if [ ! -z "$CFG_L2" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_L2 [$CFG_L2] ..."
    sed -i "s/L2:.*/L2: $CFG_L2/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut L2 ..."
fi
if [ ! -z "$CFG_URL" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_URL [$CFG_URL] ..."
    sed -i "s,URL:.*,URL: $CFG_URL," $ESQUITE_DIR/env.yaml
else
    logMsg "Using Default Elasticsearch URL ..."
fi
if [ ! -z "$CFG_SECRET_KEY" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_SECRET_KEY [$CFG_SECRET_KEY] ..."
    sed -i "s/SECRET_KEY:.*/SECRET_KEY: $CFG_SECRET_KEY/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using NEW 'random' SECRET_KEY ..."
    secret="`tr -dc A-Za-z0-9 </dev/urandom | head -c 69 ; echo ''`"
    sed -i "s/ORG_SECRET_KEY:.*/ORG_SECRET_KEY: $CFG_SECRET_KEY/" $ESQUITE_DIR/env.yaml    
fi
if [ ! -z "$CFG_ORG_NAME" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_ORG_NAME [$CFG_ORG_NAME] ..."
    sed -i "s/ORG_NAME:.*/ORG_NAME: $CFG_ORG_NAME/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut ORG_NAME ..."
fi
if [ ! -z "$CFG_GOOGLE_ANALYTICS" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_GOOGLE_ANALYTICS [$CFG_GOOGLE_ANALYTICS] ..."
    sed -i "s/GOOGLE_ANALYTICS:.*/GOOGLE_ANALYTICS: $CFG_GOOGLE_ANALYTICS/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut GOOGLE_ANALYTICS ..."
fi
if [ ! -z "$CFG_NAME" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_NAME [$CFG_NAME] ..."
    sed -i "s/NAME:.*/NAME: $CFG_NAME/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut Esquite NAME ..."
fi
if [ ! -z "$CFG_BLOG" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_BLOG [$CFG_BLOG] ..."
    sed -i "s,blog:.*,blog: $CFG_BLOG," $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut BLOG url ..."
fi
if [ ! -z "$CFG_EMAIL" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_EMAIL [$CFG_EMAIL] ..."
    sed -i "s/email:.*/email: $CFG_EMAIL/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut EMAIL address ..."
fi
if [ ! -z "$CFG_FACEBOOK" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_FACEBOOK [$CFG_FACEBOOK] ..."
    sed -i "s,facebook:.*,facebook: $CFG_FACEBOOK," $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut FACEBOOK url ..."
fi
if [ ! -z "$CFG_SITE" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_SITE [$CFG_SITE] ..."
    sed -i "s,site:.*,site: $CFG_SITE," $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut SITE url ..."
fi
if [ ! -z "$CFG_TWITTER" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_TWITTER [$CFG_TWITTER] ..."
    sed -i "s,twitter:.*,twitter: $CFG_TWITTER," $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut TWITTER url ..."
fi
if [ ! -z "$CFG_META_DESC" ] && [ $envupdate -eq 1 ]; then
    logMsg "Configuring VAR CFG_META_DESC [$CFG_META_DESC] ..."
    sed -i "s/META_DESC:.*/META_DESC: $CFG_META_DESC/" $ESQUITE_DIR/env.yaml
else
    logMsg "Using Defalut META_DESC ..."
fi


logMsg "Starting Esquite Framework ... "
execCmd "cd $ESQUITE_DIR"
execCmd "python3 manage.py migrate"
execCmd "python3 manage.py runserver 0.0.0.0:3000"
