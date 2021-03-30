#!/bin/sh
HOMEDIR="/home/elotl"
LOGFILE="$HOMEDIR/esquite-docker.log"
ESQUITE_DIR="$HOMEDIR/Esquite"
ESQUITE_DOCKER_DIR="$HOMEDIR/Esquite-docker/build"

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
sudo /bin/chown -R elotl:elotl $HOMEDIR
logMsg "############################################################"
logMsg "Starting Docker-Esquite"
logMsg "############################################################"
execCmd "sudo /bin/chown -R elotl:elotl $HOMEDIR/"
logMsg "Permissions set to homedir (ensure perms in case volumes are used) ..."
envupdate=0
ls -l $ESQUITE_DIR
if [ ! -f $ESQUITE_DIR/env.yaml ]; then
    logMsg "ENV file doesn't exist. New file will be created via wizard (quick)"
    execCmd "cd $ESQUITE_DIR/"
    execCmd "pip3 install -r requirements.txt"
    execCmd "python3 wizard.py -q"
    if [ ! -z "$CFG_INDEX" ]; then
        logMsg "Configuring VAR CFG_INDEX [$CFG_INDEX] ..."
        sed -i "s/INDEX:.*/INDEX: $CFG_INDEX/" $ESQUITE_DIR/env.yaml
    fi
    envupdate=1
fi
env_hash="`md5sum $ESQUITE_DIR/env.yaml | awk '{print $1}'`"
logMsg "ENV version: [$env_hash]"
if [ $env_hash == "2daf0e0a68bc5e87d8c4f9b1e04f935b" ]; then
    logMsg "ENV file is an empty template. Docker ENV vars will apply"
    envupdate=1
fi
logMsg "Testing Default INDEX. Waiting 10 seconds for ELASTICSEARCH container ..."
execCmd "sleep 10"
elastic-test="`curl -X GET \"esquite-elasticsearch:9200/default\"`"
if [ -z "$elastic_test" ]; then
    logMsg "Default Index does not exist. Creating NEW index"
    execCmd "curl -X PUT -H \"Content-Type: application/json\" -d @$ESQUITE_DOCKER_DIR/esquite-elasticsearch.json.template esquite-elasticsearch:9200/default"
else
    logMsg "Existing default index [default] exists."
fi

if [ ! -z "$CFG_CORPUS_ADMIN_ADMIN_PASS" ]; then
    logMsg "Setting new custom Corpus-admin password"
    echo -n "corpus-admin:" > $HOMEDIR/users.pwd; echo -n "$CFG_CORPUS_ADMIN_PASS" | mkpasswd -s -m sha-512 >> $HOMEDIR/users.pwd
else
    logMsg "Using default password for corpus-admin"
    echo -n "corpus-admin:" > $HOMEDIR/users.pwd; echo -n "elotl" | mkpasswd -s -m sha-512 >> $HOMEDIR/users.pwd
fi
if [ "$CFG_UPDATE_ON_BOOT" = "YES" ]; then
    logMsg "Update VAR enabled. Updating Esquite GIT repository ..."
    execCmd "cd $ESQUITE_DIR/"
    execCmd "git pull"
    execCmd "pip3 install -r requirements.txt"
else
    logMsg "Skipping Update on BOOT. To update enable VAR CFG_UPDATE_ON_BOOT=YES ..."
fi

logMsg "ENV update=$envupdate"
if [ $envupdate -eq 1 ]; then
    if [ ! -z "$CFG_INDEX" ]; then
        logMsg "Configuring VAR CFG_INDEX [$CFG_INDEX] ..."
        sed -i "s/INDEX:.*/INDEX: $CFG_INDEX/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Default INDEX. Waiting 10 seconds for ELASTICSEARCH container ..."
        execCmd "sleep 10"
        elastic-test="`curl -X GET \"esquite-elasticsearch:9200/default\"`"
        if [ -z "$elastic_test" ]; then
            logMsg "Default Index does not exist. Creating NEW index"
            execCmd "curl -X PUT -H \"Content-Type: application/json\" -d @$ESQUITE_DOCKER_DIR/esquite-elasticsearch.json.template esquite-elasticsearch:9200/default"
        else
            logMsg "Existing default index [default] exists."
        fi
    fi

    if [ ! -z "$CFG_L1" ]; then
        logMsg "Configuring VAR CFG_L1 [$CFG_L1] ..."
        sed -i "s/L1:.*/L1: $CFG_L1/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut L1 ..."
    fi
    if [ ! -z "$CFG_L2" ]; then
        logMsg "Configuring VAR CFG_L2 [$CFG_L2] ..."
        sed -i "s/L2:.*/L2: $CFG_L2/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut L2 ..."
    fi
    if [ ! -z "$CFG_URL" ]; then
        logMsg "Configuring VAR CFG_URL [$CFG_URL] ..."
        sed -i "s,URL:.*,URL: $CFG_URL," $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Default Elasticsearch URL ..."
    fi
    if [ ! -z "$CFG_SECRET_KEY" ]; then
        logMsg "Configuring VAR CFG_SECRET_KEY [$CFG_SECRET_KEY] ..."
        sed -i "s/SECRET_KEY:.*/SECRET_KEY: $CFG_SECRET_KEY/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using NEW 'random' SECRET_KEY ..."
        secret="`tr -dc A-Za-z0-9 </dev/urandom | head -c 69 ; echo ''`"
        sed -i "s/ORG_SECRET_KEY:.*/ORG_SECRET_KEY: $CFG_SECRET_KEY/" $ESQUITE_DIR/env.yaml    
    fi
    if [ ! -z "$CFG_ORG_NAME" ]; then
        logMsg "Configuring VAR CFG_ORG_NAME [$CFG_ORG_NAME] ..."
        sed -i "s/ORG_NAME:.*/ORG_NAME: $CFG_ORG_NAME/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut ORG_NAME ..."
    fi
    if [ ! -z "$CFG_GOOGLE_ANALYTICS" ]; then
        logMsg "Configuring VAR CFG_GOOGLE_ANALYTICS [$CFG_GOOGLE_ANALYTICS] ..."
        sed -i "s/GOOGLE_ANALYTICS:.*/GOOGLE_ANALYTICS: $CFG_GOOGLE_ANALYTICS/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut GOOGLE_ANALYTICS ..."
    fi
    if [ ! -z "$CFG_NAME" ]; then
        logMsg "Configuring VAR CFG_NAME [$CFG_NAME] ..."
        sed -i "s/NAME:.*/NAME: $CFG_NAME/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut Esquite NAME ..."
    fi
    if [ ! -z "$CFG_BLOG" ]; then
        logMsg "Configuring VAR CFG_BLOG [$CFG_BLOG] ..."
        sed -i "s,blog:.*,blog: $CFG_BLOG," $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut BLOG url ..."
    fi
    if [ ! -z "$CFG_EMAIL" ]; then
        logMsg "Configuring VAR CFG_EMAIL [$CFG_EMAIL] ..."
        sed -i "s/email:.*/email: $CFG_EMAIL/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut EMAIL address ..."
    fi
    if [ ! -z "$CFG_FACEBOOK" ]; then
        logMsg "Configuring VAR CFG_FACEBOOK [$CFG_FACEBOOK] ..."
        sed -i "s,facebook:.*,facebook: $CFG_FACEBOOK," $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut FACEBOOK url ..."
    fi
    if [ ! -z "$CFG_SITE" ]; then
        logMsg "Configuring VAR CFG_SITE [$CFG_SITE] ..."
        sed -i "s,site:.*,site: $CFG_SITE," $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut SITE url ..."
    fi
    if [ ! -z "$CFG_TWITTER" ]; then
        logMsg "Configuring VAR CFG_TWITTER [$CFG_TWITTER] ..."
        sed -i "s,twitter:.*,twitter: $CFG_TWITTER," $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut TWITTER url ..."
    fi
    if [ ! -z "$CFG_META_DESC" ]; then
        logMsg "Configuring VAR CFG_META_DESC [$CFG_META_DESC] ..."
        sed -i "s/META_DESC:.*/META_DESC: $CFG_META_DESC/" $ESQUITE_DIR/env.yaml
    else
        logMsg "Using Defalut META_DESC ..."
    fi
    execCmd "cd $ESQUITE_DIR"
    execCmd "pip3 install -r requirements.txt"
    exit
fi

#############################################################################
# Starting built-in Nginx server. Do not change this unless you want to
# change the webserver used as reverse proxy for Esquite framework
logMsg "Starting NGINX server ..."
execCmd "sudo nginx"

#############################################################################
# Add here custom services/apps to be started during container startup
# Note: If service needs root permissions, change first default sudoers config

# Example
#execCmd "sudo /opt/myapp/app"


#############################################################################
# Start of Esquite framework backend

logMsg "Starting Esquite Framework ... "
execCmd "cd $ESQUITE_DIR"
execCmd "pip3 install -r requirements.txt"
execCmd "python3 manage.py migrate"
execCmd "python3 manage.py runserver 0.0.0.0:3000"
