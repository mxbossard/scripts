#!/bin/sh

. /home/$USER/env-tomcat.sh

cp /home/$USER/logs/gc.log /home/$USER/logs/gc.log.$(date +%F_%T)

$CATALINA_HOME/bin/shutdown.sh
