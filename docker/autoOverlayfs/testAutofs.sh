#!/bin/sh

NB_MOUNT=${NB_DIR:-1000}
FS_NAME="overlayfs"

LOWER_DIR="/mnt/$FS_NAME/lower"
UPPER_DIR="/mnt/$FS_NAME/upper"
WORK_DIR="/mnt/$FS_NAME/work"
MOUNT_DIR="/mnt/$FS_NAME/mnt"

AUTOFS_FILE="/etc/auto.overlayfs"

test -d $LOWER_DIR || mkdir -p $LOWER_DIR
test -d $MOUNT_DIR || mkdir -p $MOUNT_DIR

# Build all needed directories
echo "building $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do 
	a=$((k % 100))
	upperDir="$UPPER_DIR/hash_$a/dir$k"
        workDir="$WORK_DIR/hash_$a/dir$k"
        test -d $upperDir || mkdir -p $upperDir
        test -d $workDir || mkdir -p $workDir

	if [ $a -eq 0 ]
	then
		echo -n "."
	fi
done

echo "\nconfiguring autofs for $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do
	a=$((k % 100))
	upperDir="$UPPER_DIR/hash_$a/dir$k"
        workDir="$WORK_DIR/hash_$a/dir$k"
        mountDir="$MOUNT_DIR/hash_$a/dir$k"

	echo "$k -fstype=overlay,lowerdir=$LOWER_DIR,upperdir=$upperDir,workdir=$workDir :$mountDir" >> $AUTOFS_FILE

	if [ $a -eq 0 ]
        then
                echo -n "."
        fi
done

echo "\n"
