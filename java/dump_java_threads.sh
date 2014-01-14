#!/bin/bash

readonly PID_FILE=/opt/tomcat/uportal.pid

readonly JSTACK_BIN=/usr/bin/jstack
readonly JPS_BIN=/usr/bin/jps

readonly JPROCESS_NAME=Bootstrap

readonly LOG_DIR=/home/esco/java_threads_dump/
readonly LOG_PREFIX=dump
readonly LOG_EXT=txt

readonly KEEP_NB_FILES=300

get_jpid()
{
    local readonly pid=`${JPS_BIN} | grep "${JPROCESS_NAME}" | awk '{ print $1}'`
    local result=$?

    if [ "${result}" -eq 0 ]; then
	
	if [ -n "${pid}" ]; then

	    kill -0 ${pid} 2>/dev/null
	    result=$?

	    if [ "${result}" -eq 0 ]; then
		echo "${pid}"
	    fi
	else
	    result=1
	fi
    fi
    
    return ${result}
}

pid=$(get_jpid)

result=$?

if [ "${result}" -eq 0 ]; then

    readonly DATE=`date -Iseconds`

    ${JSTACK_BIN} ${pid} > "${LOG_DIR}/${LOG_PREFIX}-${DATE}.${LOG_EXT}"

    readonly nb_files=`ls -1tr ${LOG_DIR}/${LOG_PREFIX}-*.${LOG_EXT} | wc -l`

    if [ -n "${nb_files}" ]; then
	
	if [ ${nb_files} -gt ${KEEP_NB_FILES} ]; then
	    
	    readonly nb_to_remove=$((${nb_files} - ${KEEP_NB_FILES}))

            ls -1tr ${LOG_DIR}/${LOG_PREFIX}-*.${LOG_EXT} | head -n${nb_to_remove} | xargs rm
	fi
    fi
fi