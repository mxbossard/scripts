#!/bin/bash

readonly DELAY=180
readonly CLK_TCK=`getconf CLK_TCK`
readonly THRESHOLD=98
readonly TRACES_DIR="/tmp"

declare -A THREADS_BEGIN_UTIME

readonly PROCESS_ID=`jps | grep -F Bootstrap | awk '{ print $1}'`

for thread in /proc/${PROCESS_ID}/task/*; do 

    if [ -e ${thread}/stat ]; then
	thread_id=`echo ${thread} | sed "s,/proc/${PROCESS_ID}/task/,,"`

	THREADS_BEGIN_UTIME[${thread_id}]=`cat ${thread}/stat | awk '{ print $14}'`
    fi

done

sleep ${DELAY}

for thread in ${!THREADS_BEGIN_UTIME[@]}; do 

    if [ -e /proc/${PROCESS_ID}/task/${thread}/stat ]; then
	current_utime=`cat /proc/${PROCESS_ID}/task/${thread}/stat | awk '{ print $14}'`
	last_utime=${THREADS_BEGIN_UTIME[${thread}]}
	
	cpu_usage_percent=` echo "100*(((${current_utime}-${last_utime})/${CLK_TCK})/${DELAY})" | bc -l`
	
	over_threshold=`echo "${cpu_usage_percent} > ${THRESHOLD}" | bc`
	if [ ${over_threshold} -eq 1 ]; then
	    current_date=`date +"%Y_%d_%d_%H_%M_%S"`
	    echo "The CPU usage of thread ${thread} of process ${PROCESS_ID} on the last  ${DELAY} seconds was over threshold (${cpu_usage_percent} / ${THRESHOLD}). Dumping trace in ${TRACES_DIR}/java_threads_dump_${PROCESS_ID}_${thread}_${current_date}.txt"
	    jstack -F ${PROCESS_ID} > ${TRACES_DIR}/java_threads_dump_${PROCESS_ID}_${thread}_${current_date}.txt
	fi
    fi
	    
done


