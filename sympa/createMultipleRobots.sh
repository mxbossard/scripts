#!/bin/bash

before=""
after=".list.touraine-eschool.fr"

for line in $(cat $1);
do
  ./createRobot.pl "${before}${line}${after}"
done 
