#!/bin/sh

. /home/$USER/env-tomcat.sh


# Traitement des logs
/bin/tar czf /home/$USER/logs/logs_`/bin/date +%Y-%m-%d_%Hh%Mm%Ss`.tar.gz $CATALINA_BASE/logs/* /home/$USER/logs/*.log*
find $CATALINA_BASE/logs/ -mtime +3 -print -exec /bin/rm -r \{\} \;
find /home/$USER/logs/*.log* -mtime +3 -print -exec /bin/rm -r \{\} \;

#/bin/tar czf /home/$USER/logs/logs_`/bin/date +%Y-%m-%d_%Hh%Mm%Ss`.tar.gz $CATALINA_BASE/logs/* $PORTAL_LOG_DIR/uPortal.log* /home/$USER/logs/*.log*
#find $PORTAL_LOG_DIR -mtime +3 -name "uPortal.log*" -print -exec /bin/rm -r \{\} \;
#find $CATALINA_BASE/logs/ -mtime +3 -print -exec /bin/rm -r \{\} \;
#find /home/$USER/logs/ -mtime +3 -print -exec /bin/rm -r \{\} \;

#$CATALINA_HOME/bin/catalina.sh start
$CATALINA_HOME/bin/catalina.sh jpda start
