#!/bin/bash
#set -x

# Perform a git tag on a git repo with tagname : YYYY-MM-DD_HHhMMmSSs_SUFFIX
# Where suffix is supplied in first arg $1

GIT_REPO="$HOME/git/esco-uportal"

TAG_SUFFIX="$1"
if [ -z "$TAG_SUFFIX" ]; then
	echo "No Tag suffix supplied !"
	exit 1 
fi

DATE=$(date +%Y-%m-%d_%Hh%Mm%Ss)
TAG_NAME="${DATE}_${TAG_SUFFIX}"
TAG_MESSAGE="Automatic tag from $0 with tagname ${TAG_NAME}."

cd $GIT_REPO
git tag -m '$TAG_MESSAGE' $TAG_NAME
#echo "git tag -m '$TAG_MESSAGE' $TAG_NAME"
