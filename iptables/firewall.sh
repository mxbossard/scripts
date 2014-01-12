#!/bin/sh
#------------------------------------------------------------------------------
#
# File: firewall.sh
#
# Author: Maxime Bossard <mxbossard@gmail.com>
#
# URL: http://www.mby.fr/
#
# License: Apache (version 2, or any later version).
#
# Description: start/stop iptable firewalling.
# Include some rules to log, limitate rate of some connections 
# and pare to some ddos attacks.
#------------------------------------------------------------------------------

#set -x

MY_DIR=$(dirname $0)
source "$MY_DIR/config.cfg"

function sub_reset {
	# Switch to ACCEPT policy
	$IPT -P INPUT ACCEPT
	$IPT -P FORWARD ACCEPT
	$IPT -P OUTPUT ACCEPT

	# Vider la table filter
	$IPT -t filter -F

	# Restart fail2ban
	service fail2ban restart

}

case "$1" in
start)
	sub_reset

	# ----- Logging -----
	# --- ACCEPT LOG chain
	$IPT -N ACCEPTLOG 2> /dev/null
	$IPT -A ACCEPTLOG ! -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "ACCEPT "
	$IPT -A ACCEPTLOG -j ACCEPT

	# --- DROP LOG chain
	$IPT -N DROPLOG 2> /dev/null
	$IPT -A DROPLOG ! -i $IF_VENET ! -o $IF_VENET -j $LOG $LOG_RLIMIT --log-prefix "DROP "
	$IPT -A DROPLOG -j DROP


	# ----- Autoriser loopback -----
	$IPT -A INPUT -i lo -j ACCEPT
	$IPT -A OUTPUT -o lo -j ACCEPT


	# ----- Banned IPs -----

	$IPT -N banned-ips 2> /dev/null
	$IPT -N banned-ips-tmp 2> /dev/null
	$IPT -A INPUT -j banned-ips-tmp
	$IPT -A INPUT -j banned-ips
	$IPT -A OUTPUT -j banned-ips

	$MY_DIR/banIp.sh


	# ----- Banned GeoIp -----

	$IPT -N geo-ip-drop 2> /dev/null
	$IPT -F geo-ip-drop
	$IPT -A INPUT -j geo-ip-drop
	$IPT -A OUTPUT -j geo-ip-drop

	# Drop all from suspect countries
#	$IPT -A geo-ip-drop -m geoip --src-cc A1,A2 -j DROPLOG


	# ----- DDOS protection -----

	# --- Drop new incoming tcp connections which are not SYN packets
	$IPT -A INPUT -p tcp ! --syn -m state --state NEW -j DROPLOG
	
	# --- Drop packets with fragments
	$IPT -A INPUT -f -j DROPLOG
	$IPT -A OUTPUT -f -j DROPLOG

	# --- Drop XMAS packets
	$IPT -A INPUT -p tcp --tcp-flags ALL ALL -j DROPLOG
	$IPT -A OUTPUT -p tcp --tcp-flags ALL ALL -j DROPLOG

	# --- Drop NULL packets
	$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROPLOG
	$IPT -A OUTPUT -p tcp --tcp-flags ALL NONE -j DROPLOG

	# --- Drop INVALID packets
	$IPT -A INPUT -m state --state INVALID -j DROPLOG
	$IPT -A FORWARD -m state --state INVALID -j DROPLOG
	$IPT -A OUTPUT -m state --state INVALID -j DROPLOG

	# --- ICMP (Ping) rate-limited
	$IPT -A INPUT -p icmp -j ACCEPT $ICMP_RLIMIT
	$IPT -A OUTPUT -p icmp -j ACCEPT $ICMP_RLIMIT


	# ----- Established connections are ok -----

	# Ne pas casser les connexions etablies
	$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPT -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
	$IPT -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT


	# ----- Standard I/O -----

	# DNS output
	$IPT -A OUTPUT -p tcp --dport 53 -j ACCEPT
	$IPT -A OUTPUT -p udp --dport 53 -j ACCEPT

	# SMTP output
	$IPT -A OUTPUT -p tcp --dport 25 -j ACCEPT

	# NTP
	$IPT -A OUTPUT -p udp --dport 123 -j ACCEPT
	
	# Git protocol
	$IPT -A OUTPUT -p tcp --dport 9418 -j ACCEPT
	$IPT -A OUTPUT -p tcp -d github.com --dport 22 -j ACCEPT

	
	# ----- Open Services -----

	# --- Services Open
	# SSH for Host
	$IPT -A INPUT -p tcp --dport 22 $SSH_RLIMIT -j ACCEPTLOG
	# pveproxy
	$IPT -A INPUT -p tcp --dport 8006 -j ACCEPT
	# HTTP/HTTPS
	$IPT -A INPUT -p tcp --match multiport --dport 80,443 -j ACCEPT


	# ----- Politique : interdire toute connexion par defaut -----
	$IPT -P INPUT DROP
	#$IPT -P FORWARD DROP
	$IPT -P OUTPUT DROP
	# Log all policy dropped
	#$IPT -A OUTPUT -j DROPLOG
	
	
	exit 0
	;;

stop)
	sub_reset

	exit 0
	;;
*)
	echo "Usage: firewall.sh {start|stop}"
	exit 1
	;;
esac

