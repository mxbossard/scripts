#!/bin/sh

NB_MOUNT=${NB_DIR:-1000}
FS_NAME="test"

LOWER_DIR="/mnt/$FS_NAME/lower"
UPPER_DIR="/mnt/$FS_NAME/upper"
WORK_DIR="/mnt/$FS_NAME/work"
MOUNT_DIR="/mnt/$FS_NAME/aufs"

mkdir $LOWER_DIR

# Build all needed directories
echo "building $NB_MOUNT directories ..."

for k in $(seq 1 $NB_MOUNT) 
do 
	# Split dirs into 100 dirs
	a=$((k % 100))
	upperDir="$UPPER_DIR/hash_$a/dir$k"
	workDir="$WORK_DIR/hash_$a/dir$k"
	mountDir="$MOUNT_DIR/hash_$a/dir$k"
	test -d $upperDir || mkdir -p $upperDir
	test -d $workDir || mkdir -p $workDir
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
	upperDir="$UPPER_DIR/hash_$a/dir$k"
	workDir="$WORK_DIR/hash_$a/dir$k"
	mountDir="$MOUNT_DIR/hash_$a/dir$k"
	mount -t overlay -o lowerdir=$LOWER_DIR,upperdir=$upperDir,workdir=$workDir overlay $mountDir

	if [ $a -eq 0 ]
        then
                echo -n "."
        fi
done

echo "\n"
