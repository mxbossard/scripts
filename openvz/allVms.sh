#!/bin/bash -e

#set -x

# Dir which contain all container dir
VZCTL_CMD="/usr/sbin/vzctl"
CONTAINER_DIR="/vz/private"
COMMAND="$1"

# Loop on all CT
for ctDir in $CONTAINER_DIR/*
do
	ctId=$(basename $ctDir)
	echo "------------ Processing CT #$ctId ... ----------"

	$VZCTL_CMD exec $ctId $COMMAND || true
done

