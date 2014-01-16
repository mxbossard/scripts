#!/bin/sh
#------------------------------------------------------------------------------
#
# File: init_dbus_session.sh
#
# Description: Initialize a Dbus session and keep it in /tmp
#
# Author: Maxime Bossard <mxbossard@gmail.com>
#
# URL: http://www.mby.fr/
#
#------------------------------------------------------------------------------


DBUS_TMP=/tmp/hubic_dbus_session

if [ ! -f $DBUS_TMP ]
then
        dbus-daemon --session --fork --print-address > $DBUS_TMP
fi

export DBUS_SESSION_BUS_ADDRESS=$(cat $DBUS_TMP)

#echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
