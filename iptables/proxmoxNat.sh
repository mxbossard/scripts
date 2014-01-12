#!/bin/sh
#------------------------------------------------------------------------------
#
# File: proxmoxNat.sh
#
# Author: Maxime Bossard <mxbossard@gmail.com>
#
# URL: http://www.mby.fr/
#
# License: Apache (version 2, or any later version).
#
# Description: NAT services to proxmox VMs.
#------------------------------------------------------------------------------

MY_DIR=$(dirname $0)
source "$MY_DIR/config.cfg"

function sub_reset {

	# Vider la table nat
	$IPT -t nat -F
}

function sub_nat_ct {

	ctIp=$1

	$IPT -t nat -A POSTROUTING -s $ctIp/32 -o vmbr0 -j SNAT --to-source $HOST_IP

}

case "$1" in
start)
	sub_reset

	########## NAT les ports ouvert vers les CT ##########

	# Service HTTP vers front.mby.net
	$IPT -t nat -A PREROUTING -i $IF_BR -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.0.0.10:80
	$IPT -t nat -A PREROUTING -i $IF_BR -p tcp -m tcp --dport 443 -j DNAT --to-destination 10.0.0.10:443


	########## NAT l'acces au net de chaque CT ##########

	allCtIps=$(vzlist -a | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")

	for ctIp in $allCtIps
	do
		sub_nat_ct $ctIp
	done

	# Default: all $LOCAL_SUBNET are nated
	$IPT -t nat -A POSTROUTING -s $LOCAL_SUBNET -o IF_BR -j SNAT --to-source HOST_IP

	exit 0
	;;

stop)
	sub_reset

	exit 0
	;;
*)
	echo "Usage: proxmoxNat.sh {start|stop}"
	
	exit 1
	;;
esac
