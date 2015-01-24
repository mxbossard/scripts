#!/bin/sh

NB_MOUNT=${NB_DIR:-1000}
FS_NAME="aufs"

BASE_DIR="/mnt/$FS_NAME/base"
USER_DIR="/mnt/$FS_NAME/user"
MOUNT_DIR="/mnt/$FS_NAME/mount"

test -d $BASE_DIR || mkdir -p $BASE_DIR

echo "building $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do 
	a=$((k % 100))

	userDir="$USER_DIR/hash_$a/dir$k" 
        mountDir="$MOUNT_DIR/hash_$a/dir$k" 
	test -d $userDir || mkdir -p $userDir
        test -d $mountDir || mkdir -p $mountDir

	if [ $a -eq 0 ]
	then
		echo -n "."
	fi
done

echo "\nmounting $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do
	a=$((k % 100))

	userDir="$USER_DIR/hash_$a/dir$k"
        mountDir="$MOUNT_DIR/hash_$a/dir$k"

	mount -t aufs -o br=$userDir=rw:$BASE_DIR=ro -o udba=reval none $mountDir

	if [ $a -eq 0 ]
        then
                echo -n "."
        fi
done

echo "\n"

