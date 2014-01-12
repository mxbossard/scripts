#!/bin/bash -e

#set -x

# Dir which contain all container dir
VZCTL_CMD="/usr/sbin/vzctl"
CONTAINER_DIR="/vz/private"

# Sub wich init a CT setup
function initCtSetup {
	ctId=$1

	# Install apt-utils
	#$VZCTL_CMD exec $ctId 'apt-get install apt-utils'
}

# Sub which clean a CT
function cleanCt {
	ctId=$1
	echo "cleaning CT #$ctId ..."

	# Clean orphan packages
	$VZCTL_CMD exec $ctId 'apt-get -y install deborphan ; apt-get -y remove --purge `deborphan`'
	
#	#$VZCTL_CMD exec $ctId 'aptitude autoclean'
#	#$VZCTL_CMD exec $ctId 'aptitude clean'

	$VZCTL_CMD exec $ctId 'yes | apt-get remove --purge aptitude ntp'
	$VZCTL_CMD exec $ctId 'apt-get clean'
	$VZCTL_CMD exec $ctId 'yes | apt-get autoclean'
	$VZCTL_CMD exec $ctId 'yes | apt-get autoremove'
	
	$VZCTL_CMD exec $ctId 'df -h /'
}

# Sub which update & upgrade a CT
function upgradeCt {
	ctId=$1
	echo "upgrading CT #$ctId ..."
	
	$VZCTL_CMD exec $ctId 'apt-get update'
	$VZCTL_CMD exec $ctId 'yes | apt-get upgrade'
}

# Sub which secure a CT
function secureCt {
	ctId=$1
	echo "securing CT #$ctId ..."

	# Lock root user	
	$VZCTL_CMD exec $ctId 'passwd -l root'

	#Remove other execution on some binaries
	$VZCTL_CMD exec $ctId 'chmod o-x /usr/bin/gcc*'
	$VZCTL_CMD exec $ctId 'chmod o-x /usr/bin/make'
	$VZCTL_CMD exec $ctId 'chmod o-x /usr/bin/apt-get'
	$VZCTL_CMD exec $ctId 'chmod o-x /usr/bin/aptitude'
	$VZCTL_CMD exec $ctId 'chmod o-x /usr/bin/dpkg'

}

# Loop on all CT
for ctDir in $CONTAINER_DIR/*
do
	ctId=$(basename $ctDir)

	# Test if CT is running	
	ctUp=$($VZCTL_CMD status $ctId | grep "running" | wc -l)
	if [ $ctUp -gt 0  ]
	then

		echo "------------ Processing CT #$ctId ... ----------"

		$VZCTL_CMD exec $ctId 'df -h /'

		initCtSetup $ctId

		upgradeCt $ctId
		cleanCt $ctId

		secureCt $ctId
	fi
done

