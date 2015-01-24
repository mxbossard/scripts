#!/bin/sh

NB_MOUNT=1000
BASE_DIR="/mnt/base"
MOUNT_DIR="/mnt/autofs/aufs"
AUTOFS_FILE="/etc/auto.aufs"

echo "building $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do 
	a=$((k % 100))
	dir="$MOUNT_DIR/hash_$a/dir$k"
	#echo $dir
	test -d $dir || mkdir -p $dir

	if [ $a -eq 0 ]
	then
		echo -n "."
	fi
done

echo "\nconfiguring autofs for $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do
	a=$((k % 100))
	dir="$MOUNT_DIR/hash_$a/dir$k"
	#mount -t aufs -o br=$dir=rw:$BASE_DIR=ro none $dir
	echo "$k -fstype=aufs,br=$dir=rw:$BASE_DIR=ro :$BASE_DIR" >> $AUTOFS_FILE

	if [ $a -eq 0 ]
        then
                echo -n "."
        fi
done

echo "\n"
