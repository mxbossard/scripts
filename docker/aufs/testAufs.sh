#!/bin/sh

NB_MOUNT=100000
BASE_DIR="/root/base"
MOUNT_DIR="/root/aufs"

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

echo "\nmounting $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do
	a=$((k % 100))
	dir="$MOUNT_DIR/hash_$a/dir$k"
	mount -t aufs -o br=$dir=rw:$BASE_DIR=ro none $dir

	if [ $a -eq 0 ]
        then
                echo -n "."
        fi
done

echo "\n"
