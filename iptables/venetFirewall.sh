#!/bin/sh
#------------------------------------------------------------------------------
#
# File: venetFirewall.sh
#
# Author: Maxime Bossard <mxbossard@gmail.com>
#
# URL: http://www.mby.fr/
#
# License: Apache (version 2, or any later version).
#
# Description: start/stop iptable venet firewalling.
# FORWARDed packets are dispatch in 3 chains which controll venet firewall :
# * venet-lo: 	venet loop 	venet	=> 	venet 
# * venet-in: 	venet input  	ext 	=>	venet
# * venet-out:	venet output	venet	=>	ext
#------------------------------------------------------------------------------

#set -x

MY_DIR=$(dirname $0)
source "$MY_DIR/config.cfg"

function sub_reset {

	# Vider la table filter
	$IPT -P FORWARD ACCEPT
	
	$IPT -D	FORWARD -i $IF_VENET -o $IF_VENET -j venet-lo 2> /dev/null
	$IPT -D	FORWARD ! -i $IF_VENET -o $IF_VENET -j venet-in 2> /dev/null
	$IPT -D	FORWARD -i $IF_VENET ! -o $IF_VENET -j venet-out 2> /dev/null
	
	$IPT -D ACCEPTLOG -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_LOOP " 2> /dev/null
	$IPT -D ACCEPTLOG ! -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_INPUT " 2> /dev/null
	$IPT -D ACCEPTLOG -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_OUTPUT " 2> /dev/null
	
	$IPT -D DROPLOG -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_LOOP " 2> /dev/null
	$IPT -D DROPLOG ! -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_INPUT " 2> /dev/null
	$IPT -D DROPLOG -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_OUTPUT " 2> /dev/null
	
	$IPT -t filter -F venet-lo 2> /dev/null
	$IPT -t filter -F venet-in 2> /dev/null
	$IPT -t filter -F venet-out 2> /dev/null
	
}

case "$1" in
start)
	sub_reset

	# ----- Logging -----
	# --- add logs at top of ACCEPTLOG chain
	$IPT -I ACCEPTLOG 1 -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_LOOP "
	$IPT -I ACCEPTLOG 2 ! -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_INPUT "
	$IPT -I ACCEPTLOG 3 -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT_VENET_OUTPUT "

	# --- add logs at top of DROPLOG chain
	$IPT -I DROPLOG 1 -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_LOOP "
	$IPT -I DROPLOG 2 ! -i $IF_VENET -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_INPUT "
	$IPT -I DROPLOG 3 -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP_VENET_OUTPUT "


	# ----- Bridge & Venet -----

	# venet-in chain to organize CTs traffic
	$IPT -N venet-lo 2> /dev/null
	$IPT -N venet-in 2> /dev/null
	$IPT -N venet-out 2> /dev/null
	# looping trafic to venet-lo
	# incoming trafic to venet-in
	# outgoing trafic to venet-out
	$IPT -A FORWARD -i $IF_VENET -o $IF_VENET -j venet-lo
	$IPT -A FORWARD ! -i $IF_VENET -o $IF_VENET -j venet-in
	$IPT -A FORWARD -i $IF_VENET ! -o $IF_VENET -j venet-out

	
	# ----- Global Vnet configuration -----	

	# Enable DNS access from CTs
	$IPT -A venet-out -p tcp --dport 53 -j ACCEPT
	$IPT -A venet-out -p udp --dport 53 -j ACCEPTLOG

	# Enable HTTP access to debian repositories
	$IPT -A venet-out -p tcp -d security.debian.org,ftp.debian.org --dport 80 -j ACCEPT

	# ----- CTs Vnet Configuration -----

	# --- backup.mby.net
	# Authorize backup to ssh all CTs
	$IPT -A venet-lo -p tcp -s backup.mby.net --dport 22 -j ACCEPT

	# --- ns.mby.net
	# Authorize all CTs to access DNS on ns.mby.net
	$IPT -A venet-lo -p tcp -d ns.mby.net --dport 53 -j ACCEPT
	$IPT -A venet-lo -p udp -d ns.mby.net --dport 53 -j ACCEPT

	# --- mailhost.mby.net
	# Authorize all CTs to send mail to mailhost.mby.net
	$IPT -A venet-lo -p tcp -d mailhost.mby.net --dport 25 -j ACCEPT
	# Authorize mailhost to send mails
	$IPT -A venet-out -p tcp -s mailhost.mby.net --dport 25 -j ACCEPT

	# --- front.mby.net
	# Authorize HTTP/HTTPS trafic to front.mby.net
	$IPT -A venet-in -p tcp -d front.mby.net --match multiport --dport 80,443 -j ACCEPT
	# Authorize front to HTTP proxy over all CTs.
	$IPT -A venet-lo -p tcp -s front.mby.net --dport 80 -j ACCEPT
	# Authorize NFS mount of scm.mby.net and http proxy to 9292
	$IPT -A venet-lo -p tcp -s front.mby.net -d scm.mby.net --match multiport --dport 111,2049,4002,9292 -j ACCEPT
	$IPT -A venet-lo -p udp -s front.mby.net -d scm.mby.net --match multiport --dport 111,2049,4002 -j ACCEPT

	
	# Drop all by default
	$IPT -P FORWARD DROP
	$IPT -A venet-lo -j DROPLOG
	$IPT -A venet-in -j DROPLOG
	$IPT -A venet-out -j DROPLOG

	exit 0
	;;

stop)
	sub_reset

	exit 0
	;;
*)
	echo "Usage: venetFirewall.sh {start|stop}"
	exit 1
	;;
esac

