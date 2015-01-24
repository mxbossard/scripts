#!/bin/sh

APP_NAME="testAufs"

APP_DIR="/tmp/$APP_NAME"
echo $APP_DIR

test -d $APP_DIR || mkdir -p $APP_DIR

docker build -t mxbossard/aufs .

docker run --rm -ti --privileged -e NB_DIR=1000 -v $APP_DIR:/mnt/aufs mxbossard/aufs
