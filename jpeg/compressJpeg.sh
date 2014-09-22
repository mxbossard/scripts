#!/bin/bash

set -x

if [ -n "$1" ]
then
        export QUALITY_RATE="$1"
else
	export QUALITY_RATE="80"
fi

if [ -n "$2" ]
then
	FILES="$2"
else
	FILES='*'
fi

DIR="$(pwd)"
cd $DIR


export TRANS_LABEL_DIR="compress"
export TRANS_DIR="./$TRANS_LABEL_DIR$QUALITY_RATE"

VERBOSE="-v"
#VERBOSE=""
PROGRESSIVE="--all-progressive"

test -d $TRANS_DIR || mkdir $TRANS_DIR
rm -r "$TRANS_DIR/*"

function transform
{
	FILE_PATH=$1
	TRANS_PATH="$TRANS_DIR/$FILE_PATH"
	echo "Compressing $FILE_PATH => $TRANS_PATH ..."

	TRANS_PATH_DIR=$(dirname $TRANS_PATH)
	test -d $TRANS_PATH_DIR || mkdir -p $TRANS_PATH_DIR

#	cjpeg $VERBOSE -quality $QUALITY_RATE -outfile $TRANS_PATH $FILE_PATH 
	jpegoptim $VERBOSE -p -t -m $QUALITY_RATE -d $TRANS_DIR $PROGRESSIVE $FILE_PATH 
}

export -f transform

# Compress jpeg.
find . -not -path "*$TRANS_LABEL_DIR*" -name "$FILES" -type f -exec bash -c 'transform "$0"' {} \;

