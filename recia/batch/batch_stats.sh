#!/bin/bash

# Pour la compression manuelle, utiliser :
# java -jar indicators-backend.jar [WEEK | MONTH] [Premier jour periode]

# Configuration
MAIL_RECIPENT=ent@recia.fr
ERROR_LOG_FILE="/tmp/indicators_backend_errors.log"
OUTPUT_LOG_FILE="/tmp/indicators_backend.log"
SCRIPT_DIR=$( cd "$( dirname "$0" )" && pwd )
BATCH_DIR=$SCRIPT_DIR
BATCH_JAR="indicators-backend.jar"
LOG4J_FILE="$BATCH_DIR/conf/log4j.xml"

# Java configuration
VM_ARGS="-Xmx2048m -XX:+UseParallelOldGC"
SYS_PROPS="-Dfile.encoding=UTF-8 -Duser.language=fr -Duser.contry=FR -Dlog4j.configuration=file:$LOG4J_FILE"

# Choix du fichier mensuel de stats
STATS_FILE="$1"
if [[ -z "$STATS_FILE"  ]]; then
# No file in arg so choose last cleaned log file (sorted by time => younger file)
STATS_FILE=$(ls -t1 /home/esco/indicateurs/data/in/cleaned_logs/* | head -1)
fi

# Context dir
cd $BATCH_DIR

# Run batch in default mode : AUTO
# Pour desactiver la compression : utiliser OFF : 
java $VM_ARGS $SYS_PROPS -jar $BATCH_JAR AUTO $STATS_FILE 2> $ERROR_LOG_FILE | tee $OUTPUT_LOG_FILE

EXIT_STATUS=$?

if [[ $EXIT_STATUS -ne 0 || -s $ERROR_LOG_FILE ]]; then
	# Error status code or errors in error file
	mail -s "[Indicators Backend] ERROR while processing batch !" $MAIL_RECIPENT < $OUTPUT_LOG_FILE
fi
