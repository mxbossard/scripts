#!/bin/sh

APP_NAME="testOverlayfs"

APP_DIR="/tmp/$APP_NAME"
echo $APP_DIR

test -d $APP_DIR || mkdir -p $APP_DIR

docker build -t mxbossard/auto-overlayfs .

docker run --rm -ti --privileged -e NB_DIR=1000 -v $APP_DIR:/mnt/overlayfs mxbossard/auto-overlayfs
