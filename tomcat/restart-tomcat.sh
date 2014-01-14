#!/bin/bash
echo "====================================================================="
echo "====================================================================="
echo "Redémarrage du : "`date`
echo "====================================================================="
echo "====================================================================="

. /home/$USER/env-tomcat.sh

>/home/esco/dead.letter

/home/$USER/stop-esco.sh

DEPLOYWAR="deployWar";
DEPLOYEAR="deployEar";

# Attente avant relance :
/bin/sleep 30

# Arret force du portail si non encore arrete :
if /bin/netstat -na | /bin/grep 8009 | /bin/grep LISTEN
	then /bin/kill -9 `/bin/ps -ef | /bin/grep java | /bin/grep -v grep | /usr/bin/awk '{print $2}'`
fi

pid=`jps | grep  Bootstrap | cut -f 1 -d ' '`
if [ -n "$pid" ] ;
then
        kill -9 $pid
fi

sleep 5

# Supression repertoire work :
/bin/rm -rf $CATALINA_BASE/work/
/bin/rm -rf $CATALINA_BASE/temp/*

echo "test : $1"

if [ "$1" == "$DEPLOYWAR" ]; then
	cd /home/$USER/esco-uportal/
	echo "WARNING : uPortal-war deployment !"
	# MBD: Perform a tag
	/home/$USER/scripts/git-tag-esco-uportal.sh "deploy-war"
	/home/$USER/ant.sh -Dmaven.test.skip=true clean deploy-war
	cd /home/$USER/
fi

if [ "$1" == "$DEPLOYEAR" ]; then
	cd /home/$USER/esco-uportal/
	echo "WARNING : uPortal-ear deployment !"
	# MBD: Perform a tag
	/home/$USER/scripts/git-tag-esco-uportal.sh "deploy-ear"
	/home/$USER/ant.sh -Dmaven.test.skip=true clean deploy-ear
	cd /home/$USER/
fi


# Relance du portail :

/home/$USER/start-esco.sh

# Attente que le portail soit relance :
while ! /bin/netstat -na | /bin/grep 8009 | /bin/grep LISTEN
  do /bin/sleep 1
done

# Compilation forcee du portail :
#hostname=$(hostname -s)
#/usr/bin/wget https://$hostname.giprecia.net:8443/portail/ --ca-certificate=/usr/local/ssl/ca/giprecia.net-cacert.pem
#echo "Check restart : `/bin/date`" >> /home/$USER/.status
# Suppression du fichier recupere par wget :
#rm render.userLayoutRootNode.uP*
#rm index.html

sleep 20

# Launch logging of jstat info
#/home/$USER/scripts/jstatLog.sh

/usr/bin/wget https://lycees.netocentre.fr/portail/ --header "Cookie: JSESSIONID=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1.$PORTAL_NUM"
rm index.html

/usr/bin/wget https://cfa.netocentre.fr/portail/ --header "Cookie: JSESSIONID=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2.$PORTAL_NUM"
rm index.html

/usr/bin/wget https://www.touraine-eschool.fr/portail/ --header "Cookie: JSESSIONID=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3.$PORTAL_NUM"
rm index.html
echo "Check restart : `/bin/date`" >> /home/$USER/.status

