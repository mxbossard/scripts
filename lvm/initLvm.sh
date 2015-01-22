#!/bin/sh

PV="$1"
VG="$2"
TP="tp_$VG"

FSTAB="/etc/fstab"

umount $PV

pvcreate $PV
pvs

vgcreate $VG $PV
vgs

lvcreate -T $VG/$TP -l 100%VG
lvs

lvcreate -T $TP -V 40% --name var_tp
lvcreate -T $TP -V 20G --name home_tp
lvcreate -T $TP -V 20% --name backups_tp
lvcreate -T $TP -V 40% --name share_tp

mkfs.ext4 /dev/mapper/$VG/*

mkdir -p /mnt/share /var/backups /home
mkdir -p /mnt/tmp/var /mnt/tmp/backups /mnt/tmp/home /mnt/tmp/share

mount /dev/mapper/$VG/var_tp /mnt/tmp/var
mount /dev/mapper/$VG/backups_tp /mnt/tmp/backups
mount /dev/mapper/$VG/home_tp /mnt/tmp/home
mount /dev/mapper/$VG/share_tp /mnt/tmp/share

mv /var/backups/* /mnt/tmp/backups
mv /var/* /mnt/tmp/var
mv /home/* /mnt/tmp/home

umount /mnt/tmp/*

chmod 000 /mnt/share /var/backups /var /home

echo "/dev/mapper/$VG/var_tp		/var		ext4	errors=remount-ro	0	1" >> $FSTAB
echo "/dev/mapper/$VG/backups_tp	/var/backups	ext4	errors=remount-ro	0	1" >> $FSTAB
echo "/dev/mapper/$VG/home_tp		/home		ext4	errors=remount-ro	0	1" >> $FSTAB
echo "/dev/mapper/$VG/share_tp		/share		ext4	errors=remount-ro	0	1" >> $FSTAB


