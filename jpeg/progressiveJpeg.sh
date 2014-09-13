#!/bin/bash

set -x

if [ -n "$1" ]
then
	FILES="$1"
else
	FILES='*'
fi

DIR="$(pwd)"
cd $DIR

export TRANS_DIR="./progressive"
#VERBOSE="-verbose"
VERBOSE=""

test -d $TRANS_DIR || mkdir $TRANS_DIR
rm $TRANS_DIR/*

function transform
{
	FILE_PATH=$1
	TRANS_PATH="$TRANS_DIR/$FILE_PATH"
	echo "Transforming $FILE_PATH => $TRANS_PATH ..."

	TRANS_PATH_DIR=$(dirname $TRANS_PATH)
	test -d $TRANS_PATH_DIR || mkdir -p $TRANS_PATH_DIR

	jpegtran $VERBOSE -copy all -progressive -outfile $TRANS_PATH $FILE_PATH 
}

export -f transform

# Create a progressive jpeg.
find . -not -path "$TRANS_DIR*" -name "$FILES" -type f -exec bash -c 'transform "$0"' {} \;

