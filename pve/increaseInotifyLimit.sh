#!/bin/sh

# Increase the INotify limit in case of "INotify: Too many open files"
LIMIT=2048
FILE="/proc/sys/fs/inotify/max_user_instances"

echo $LIMIT > $FILE
