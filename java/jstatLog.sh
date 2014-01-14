#!/bin/bash

nohup jstat -gccause $(jps | grep Bootstrap | cut -d" " -f1) 5000 > /home/esco/logs/jstat.log.$(date +%F_%T) &
