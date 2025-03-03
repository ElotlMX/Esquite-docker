#!/bin/sh
HOMEDIR="/home/elotl/"
LOGFILE="$HOMEDIR/logs/esquite-docker.log"
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
#execCmd "sudo /bin/chown -R elotl:elotl $HOMEDIR/"
logMsg "Permissions set to homedir (ensure perms in case volumes are used) ..."

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
logMsg "Checking Elasticsearch config ..."
if [ "$CFG_ESQUITE_ELASTICSEARCH" = "default-esquite" ]; then
    logMsg "Checking if default index 'default-esquite' already exists ..."
    elastic-test="`curl -X GET \"esquite-elasticsearch:9200/default-esquite\"`"
    if [ -z "$elastic_test" ]; then
    logMsg "Default Index does not exist. Creating NEW index"
    execCmd "curl -X PUT -H \"Content-Type: application/json\" -d @$ESQUITE_DIR/esquite-elasticsearch.json.template esquite-elasticsearch:9200/default-esquite"
    else
        logMsg "Default index [default-esquite] already exists."
    fi
else
    logMsg "Variable CFG_ESQUITE_ELASTICSEARCH is not defined. Default index [default-esquite] will NOT be created."
fi


logMsg "Starting Esquite Framework ... "
execCmd "cd /home/elotl/Esquite && /home/elotl/.local/bin/poetry run python manage.py migrate"
esquite_ip="`ip --brief address show| grep eth| awk '{print $NF}' | sed 's/\/.*//g'`"
logMsg "Esquite Web is available on "
logMsg "  - http://$esquite_ip "
execCmd "cd /home/elotl/Esquite && /home/elotl/.local/bin/poetry run python manage.py runserver 127.0.0.1:3000"
