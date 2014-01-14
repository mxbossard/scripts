#!/bin/sh

export LANG=fr_FR.UTF-8

export JAVA_HOME=/usr/lib/java
export MVN_HOME=/usr/local/maven
export M2_HOME=$MVN_HOME
export ANT_HOME=/usr/local/ant

export PORTAL_LOG=/home/esco/logs/uPortal.log
export PORTAL_LOG_DIR=/home/esco/logs
export PORTAL_HOME=/home/esco/esco-uportal
export PORTAL_NUM=netocentre1

export CATALINA_HOME=/usr/local/tomcat
export CATALINA_BASE=/opt/tomcat
export CATALINA_TMPDIR=$CATALINA_BASE/temp

#export TRUST_CERT=/usr/local/ssl/ca/ca-giprecia.keystore
#export CATALINA_OPTS=-Djavax.net.ssl.trustStore="$TRUST_CERT"
#export CATALINA_OPTS="-Djavax.net.ssl.trustStore=/usr/local/ssl/ca/ca-giprecia.keystore -Dsun.security.ssl.allowUnsafeRenegotiation=true"
export CATALINA_OPTS="-Djavax.net.ssl.trustStore=/usr/local/ssl/ca/ca-giprecia.keystore"
export CATALINA_PID=/opt/tomcat/uportal.pid


export JAVA_OPTS="$JAVA_OPTS -server -Xms2360m -Xmx2360m -XX:PermSize=480m -XX:MaxPermSize=480m -XX:+UseParallelGC"
#export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=3600 -Dhttps.protocols=SSLv3,TLSv1,SSLv2Hello"

# Heap tuning
export JAVA_OPTS="$JAVA_OPTS -XX:NewRatio=3"

# Troubleshot memory problems
export JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/esco/java_heap_dump/ -XX:+PrintClassHistogram -XX:+PrintConcurrentLocks"
export JAVA_OPTS="$JAVA_OPTS -verbose:gc -Xloggc:/home/esco/logs/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintPromotionFailure -XX:PrintFLSStatistics=1 -XX:-PrintTenuringDistribution"
#export JAVA_OPTS="$JAVA_OPTS -XX:+PrintHeapAtGC"
export JAVA_OPTS="$JAVA_OPTS -XX:ErrorFile=/home/esco/logs/hs_err_pid%p.log -XX:+UseGCOverheadLimit -XX:GCTimeLimit=98 -XX:GCHeapFreeLimit=2"

export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=3600 -Dhttps.protocols=SSLv3"
export JAVA_OPTS="$JAVA_OPTS -Djava.awt.headless=true -Dcom.sun.management.jmxremote"
export JAVA_OPTS="$JAVA_OPTS -Dfile.encoding=UTF-8"

#export JAVA_OPTS="$JAVA_OPTS -Djavax.net.debug=all"

#export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=7777 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

export JPDA_ADDRESS=6665
export JPDA_TRANSPORT=dt_socket

# TO USE PROXY
#export ANT_OPTS="-Dhttp.proxyHost=proxy.univ.fr -Dhttp.proxyPort=8080"
#export JAVA_OPTS="$JAVA_OPTS -Dhttp.nonProxyHosts=*.univ.fr|localhost -Dhttp.proxyHost=proxy.univ.fr -Dhttp.proxyPort=8080"


###########################################
########## uPortal configuration ##########
###########################################

#Clustering uPortal (jGroups)
#export JAVA_OPTS="$JAVA_OPTS -Djgroups.tcpping.initial_hosts=192.168.1.91[42200]"

# pour calendarportlet - afin que les alarms ne posent pas de pb par ex.
export JAVA_OPTS="$JAVA_OPTS -Dical4j.parsing.relaxed=true"

# paramètres du nom de domaine public, url interne et numéro de portail
export JAVA_OPTS="$JAVA_OPTS -DescoENTServerHost=ent.netocentre.fr"
export JAVA_OPTS="$JAVA_OPTS -DescoENTServerHostNum=portail1.netocentre.fr"
export JAVA_OPTS="$JAVA_OPTS -DescoENTPortailNum=$PORTAL_NUM"

ulimit -n 8192
