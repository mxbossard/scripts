#!/bin/sh
script_date=`/bin/date +%Y-%m-%d`

cd /opt/tomcat/logs/

tail -f catalina.out > catalina.out.tail &
pid=$!
ps -ef | grep "tail"
echo $pid
cp -f catalina.out catalina.out.$script_date && cat /dev/null > catalina.out
kill -9 $pid
echo '============== tail' >> catalina.out.$script_date
cat catalina.out.tail >> catalina.out.$script_date
/bin/rm catalina.out.tail


tail -f catalina.0.log > catalina.0.log.tail &
pid=$!
cp -f catalina.0.log catalina.0.log.$script_date && cat /dev/null > catalina.0.log
kill -9 $pid

echo '============== tail' >> catalina.0.log.$script_date
cat catalina.0.log.tail >> catalina.$script_date.log
/bin/rm catalina.0.log.tail 
