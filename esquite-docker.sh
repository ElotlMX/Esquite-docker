#!/bin/bash
# Esquite Basic Controller script v0.1
# contacto@elotl.mx
get_info () {
    cnt_base_app="`pwd | sed -r 's/.*\/([^\/]+)$/\1/' | tr '[:upper:]' '[:lower:]'`_app_"
    cnt_base_els="`pwd | sed -r 's/.*\/([^\/]+)$/\1/' | tr '[:upper:]' '[:lower:]'`_elasticsearch_"
    cnt_name_app="`docker ps -a | grep -o "$cnt_base_app.*"`"
    cnt_name_els="`docker ps -a | grep -o "$cnt_base_els.*"`"
    if [ ! -z "$cnt_name_app" ]; then
        cnt_ip_app="`docker inspect $cnt_name_app | egrep  'IPAddress.*[0-9]+\.'| grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`"
    fi
    if [ ! -z "$cnt_name_els" ]; then
        cnt_ip_els="`docker inspect $cnt_name_els | egrep  'IPAddress.*[0-9]+\.'| grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'`"
    fi
}

destroy_cnt () {
    if [ $2 == "es" ]; then
        echo "En verdad desea $1 el siguiente container ?"
        echo "  Esquite App           -> $cnt_name_app"
        echo "  Esquite Elasticsearch -> $cnt_name_els"
        echo
        echo -n "Escriba \"Si\" para confirmar : "
    elif [ $2 == "en" ]; then
        echo "Do you really want to $1 the following Containers ?"
        echo "  Esquite App           -> $cnt_name_app"
        echo "  Esquite Elasticsearch -> $cnt_name_els"
        echo
        echo -n "Type \"Yes\" to confirm : "
    elif [ $2 == "na" ]; then
        echo "Nahuatl pendiente: :(. En verdad desea  $1 los containers?"
        echo "  Esquite App           -> $cnt_name_app"
        echo "  Esquite Elasticsearch -> $cnt_name_els"
        echo
        echo -n "Tlacuiloa \"Quemah\" nic tlachicahua : "
    fi 
    read destroy
    if [ $destroy == "Yes" ] || [ $destroy == "Si" ] || [ $destroy == "Quemah" ]; then
        if [ -z "$cnt_name_app" ]; then
            echo "Esquite APP container: [Does not exist | No existe | Amo catl]"
        else
            echo "Container [$cnt_name_app]  [Destroying | Destruyendo | Tlapoloa] ..."
            docker rm -f $cnt_name_app
        fi
        if [ -z "$cnt_name_els" ]; then
            echo "Esquite ELASTICSEARCH container: [Does not exist | No existe | Amo catl]"
        else
            echo "Container [$cnt_name_els]  [Destroying | Destruyendo | Tlapoloa] ..."
            docker rm -f $cnt_name_els
        fi
    else
        if [ $2 == "es" ]; then 
            echo "Destroy command confirmation unsuccessful. Containers are safe!"
        elif [ $2 == "es" ]; then 
            echo "Confirmación de destrucción de container no fue satisfactoria. Los containers no se borraron"
        elif [ $2 == "na" ]; then 
            echo "NAHUATL: no disponible :(. Confirmación de destrucción de container no fue satisfactoria. Los containers no se borraron"
        fi
        exit
    fi
}

info () {
    if [ -z "$cnt_name_app" ]; then
        echo "Esquite APP container: [Does not exist | No existe | Amo catl]"
    else
        echo "Esquite APP           : [$cnt_ip_app]-[$cnt_name_app]"
    fi
    if [ -z "$cnt_name_els" ]; then
        echo "Esquite ELASTICSEARCH container: [Does not exist | No existe | Amo catl]"
    else
        echo "Esquite ELASTICSEARCH : [$cnt_ip_els]-[$cnt_name_els]"
    fi
}

start () {
    CWD=`pwd`
    if [ ! -f "$CWD/logs/esquite-docker.log" ]; then 
        echo "Creating docker log file for consistency ..."
        mkdir "$CWD/logs"
        touch "$CWD/logs/esquite-docker.log"
    fi
    docker-compose up -d
    sleep 5
    get_info
    get_info
    info
    echo
    echo "##############################################################################"
    echo "                     <ESQUITE>  Comunidad ElotlMX"
    echo
    echo "[EN] You can access Esquite Web [$cnt_name_app] on http://$cnt_ip_app"
    echo "[ES] Puedes acceder a Esquite Web [$cnt_name_app] en http://$cnt_ip_app"
    echo "[NA] Calaqui Esquite Web [$cnt_name_app]  http://$cnt_ip_app"
    echo
    echo "[EN] If Any port was exposed in the docker-compose file, you can access Esquite on:"
    echo "[ES] Si algún puerto fue expuesto en el archivo docker-compose, puede acceder en:"
    echo
    echo "     > http://localhost:PORT       -->   By default: http://localhost"
    echo
    echo "##############################################################################"
    echo
}

stop () {
    if [ -z "$cnt_name_app" ]; then
        echo "Esquite APP container: [Does not exist | No existe | Amo catl]"
    else
        echo "Container [$cnt_name_app] [Stopping | Deteniendo | Cahua ] ..." && docker stop $cnt_name_app
    fi
    if [ -z "$cnt_name_els" ]; then
        echo "Esquite ELASTICSEARCH container: [Does not exist | No existe | Amo catl]"
    else
        echo "Container [$cnt_name_els] [Stopping | Deteniendo | Cahua ] ..." && docker stop $cnt_name_els
    fi
}

restart() {
    if [ "$1" == "els" ] || [ "$1" == "all" ]; then
        if [ -z "$cnt_name_els" ]; then
            echo "Esquite ELASTICSEARCH container: [Does not exist | No existe | Amo catl]"
        else
            echo "Container [$cnt_name_els] [Restarting | Reiniciando | Re-pehualtia] ..." && docker restart $cnt_name_els
        fi
    fi
    if [ "$1" == "app" ] || [ "$1" == "all" ]; then
        if [ -z "$cnt_name_app" ]; then
            echo "Esquite APP container [Does not exist | No existe | Amo catl]"
        else
            echo "Container [$cnt_name_app] [Restarting | Reiniciando | Re-pehualtia] ..." && docker restart $cnt_name_app
        fi
    fi
}

update () {
    if [ $1 == "es" ]; then
        echo "En realidad desea actualizar Esquite?"
        echo "Advertencia:"
        echo " --> Cualquier cambio en los archivos internos de esquite podria perderse. Por favor guarde un respaldo manualmente"
        echo " --> Si no se hizo ningun cambio a los archivos internos, la actualizacion deberia funcionar bien"
        echo
        echo -n "Escriba \"Si\" para confirmar : "
    elif [ $1 == "en" ]; then
        echo "Do you want to Update Esquite?"
        echo "Warning:"
        echo " --> Any local change to Esquite core files may be lost. Please backup first and restore manually"
        echo " --> If no changes to core files have been done, update should work fine"
        echo
        echo -n "Type \"Yes\" to confirm : "
    elif [ $1 == "na" ]; then
        echo "Nahuatl NO disponible :("
        echo "En realidad desea actualizar Esquite?"
        echo "Advertencia:"
        echo " --> Cualquier cambio en los archivos internos de esquite podria perderse. Por favor guarde un respaldo manualmente"
        echo " --> Si no se hizo ningun cambio a los archivos internos, la actualizacion deberia funcionar bien"
        echo
        echo -n "Escriba \"Quemah\" para confirmar : "
    fi
    read update
    if [ $update == "Yes" ] || [ $update == "Si" ] || [ $update == "Quemah" ] ; then
        echo "(Updating | Actualizando) via GIT ..."
        git pull --recurse-submodules
        git submodule update --remote
        restart "app"
    else
        echo "[EN] Update confirmation unsuccesful. No updates have been applied"
        echo "[ES] Confirmación de destrucción de container no fue satisfactoria. Los containers no se borraron"
    fi

}

banner () {
    echo "##############################################"
    echo " Esquite Docker script   - Comunidad ElotlMX  "
    echo "----------------------------------------------"
    echo " Github: https:///github.com/elotlmx"
    echo " Web   : Elotl.mx"
    echo "##############################################"
    echo
}

banner
if [ "$#" -ne 1 ]; then
    echo
    echo "[EN ] ERROR: Unknown Option: Syntax:    ./esquite-docker (start|stop|restart|destroy|info|update|recreate)"
    echo "[ES ] ERROR: Opción no valida. Sintaxis:    ./esquite-docker (iniciar|detener|reiniciar|destruir|info|actualizar|recrear)"
    echo "[NAH] TLATLACOLLI: Opción no valida. Sintaxis:    ./esquite-docker (pehualtia|cahua|re-pehualtia|tlapoloa|tlanonotzaliztli|yancuic|tlaana)"
    echo
    exit
fi
get_info

if [ $1 == "start" ]; then
    start "en" 
elif [ $1 == "iniciar" ] ; then
    start "es" 
elif [ $1 == "pehualtia" ]; then
    start "na" 
elif [ $1 == "restart" ] ; then
    restart "all"
    info "en"
elif [ $1 == "reiniciar" ] ; then
    restart "all"
    info "es"
elif [ $1 == "re-pehualtia" ]; then
    restart "all"
    info "na"
elif [ $1 == "stop" ]; then
    stop "en"
elif [ $1 == "detener" ]; then
    stop "en"
elif [ $1 == "cahua" ]; then
    stop "en"
elif [ $1 == "info" ]; then
    info "es"
elif [ $1 == "tlanonotzaliztli" ]; then
    info "na"
elif [ $1 == "recreate" ]; then
    destroy_cnt "Recreate" "en"
    echo "*********************"
    start "en"
elif  [ $1 == "recrear" ]; then
    destroy_cnt "Recreate" "es"
    echo "*********************"
    start "es"
elif [ $1 == "tlaana" ]; then
    destroy_cnt "Recreate" "na"
    echo "*********************"
    start "na"
elif [ $1 == "destroy" ]; then
    destroy_cnt "Destroy" "en"
elif [ $1 == "destruir" ]; then
    destroy_cnt "Destroy" "es"
elif [ $1 == "tlapoloa" ]; then
    destroy_cnt "tlapoloa" "na"
elif [ $1 == "update" ]; then
    update "en"
elif [ $1 == "actualizar" ]; then
    update "es"
elif [ $1 == "yancuic" ]; then
    update "na"
else
    echo "[EN ] ERROR: Unknown Option: Syntax:    ./esquite-docker (start|stop|restart|destroy|info|update|recreate)"
    echo "[ES ] ERROR: Opcion no valida. Sintaxis:    ./esquite-docker (iniciar|detener|reiniciar|destruir|info|actualizar|recrear)"
    echo "[NAH] TLATLACOLLI: Opcion no valida. Sintaxis:    ./esquite-docker (pehualtia|cahua|re-pehualtia|tlapoloa|tlanonotzaliztli|yancuic|tlaana)"
    echo
fi
