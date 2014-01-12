#!/bin/sh
#------------------------------------------------------------------------------
#
# File: banIp.sh
#
# Author: Maxime Bossard <mxbossard@gmail.com>
#
# URL: http://www.mby.fr/
#
# License: Apache (version 2, or any later version).
#
# Description: Add banned IPs to iptables banned-ips chain 
# and add the IP passed in parameterto the banned-ips-tmp chain.
#------------------------------------------------------------------------------

BANNED_IPS=""

IPT="/sbin/iptables"

if [ ! -z $1 ]
then
	$IPT -A banned-ips-tmp -s $1 -j DROPLOG
fi

$IPT -F banned-ips

for bannedIp in $BANNED_IPS
do
	$IPT -A banned-ips -s $bannedIp -j DROPLOG
done
