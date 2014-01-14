#!/bin/bash

LOCAL_ESCO_HOME='/home/esco'
REMOTE_ESCO_HOME='/home/esco'
RSYNC=/usr/bin/rsync
RSYNC_OPT='-arv'
RSYNC_SYMLINKS_OPT='-L'
DEST='epervier'

if [ -d "${LOCAL_ESCO_HOME}" ]; then
    ${RSYNC} ${RSYNC_OPT} ${LOCAL_ESCO_HOME}/*.sh ${DEST}:${REMOTE_ESCO_HOME}/ >/dev/null
    RES=$?

    if [ ${RES} -ne 0 ]; then
	echo "Copy of shell scripts to ${DEST} failed with ${RES}";
	exit ${RES}
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} ${LOCAL_ESCO_HOME}/conf-cas-saml-prod ${DEST}:${REMOTE_ESCO_HOME}/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of ${LOCAL_ESCO_HOME}/conf-cas-saml-prod scripts to ${DEST} failed with ${RES}";
	exit $RES
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} ${LOCAL_ESCO_HOME}/conf-cas-saml-test ${DEST}:${REMOTE_ESCO_HOME}/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of ${LOCAL_ESCO_HOME}/conf-cas-saml-test scripts to ${DEST} failed with ${RES}";
	exit $RES
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} ${LOCAL_ESCO_HOME}/CAS-production-version/custom ${DEST}:${REMOTE_ESCO_HOME}/CAS-production-version/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of ${LOCAL_ESCO_HOME}/CAS-production-version/custom scripts to ${DEST} failed with ${RES}";
	exit $RES
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} ${LOCAL_ESCO_HOME}/CAS-production-version/resources ${DEST}:${REMOTE_ESCO_HOME}/CAS-production-version/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of ${LOCAL_ESCO_HOME}/CAS-production-version/resources scripts to ${DEST} failed with ${RES}";
	exit $RES
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} ${LOCAL_ESCO_HOME}/CAS-test-version ${DEST}:${REMOTE_ESCO_HOME}/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of ${LOCAL_ESCO_HOME}/CAS-test-version scripts to ${DEST} failed with ${RES}";
	exit $RES
    fi

    ${RSYNC} ${RSYNC_OPT} ${RSYNC_SYMLINKS_OPT} --exclude 'shibboleth-idp/logs/' /opt/shibboleth-idp ${DEST}:/opt/ >/dev/null
    RES=$?
    
    if [ ! $RES -eq 0 ]; then
	echo "Copy of /opt/shibboleth-idp to ${DEST} failed with ${RES}";
	exit $RES
    fi

fi

