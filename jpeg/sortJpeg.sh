#!/bin/sh

if [ -n "$1" ]
then
	COMMON_NAME="$1"
else
	COMMON_NAME=""
fi

if [ -n "$2" ]
then
	FILES="$2"
else
	FILES="*"
fi

# Rename, move, and update fs timestamps of jpegs
#jhead -ft -n%Y%m%d-%H/%04i_${COMMON_NAME}_%Y%m%d-%H%M%S -exonly $FILES
jhead -ft -n%03i_${COMMON_NAME}_%Y%m%d-%H%M%S -exonly $FILES

chown -R www-data:www-data $FILES

