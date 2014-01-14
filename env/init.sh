#!/bin/bash

nbTerm=5;
commandsToRun="directoryStudio sts";

for (( k=1; k<=$nbTerm; k++ ));
do
	/usr/bin/term -m -b -l"4x1" -T "term $k" 2>&1 > /dev/null &
done

for ctr in $commandsToRun;
do
	/usr/bin/term -T"$ctr" -e"$ctr" 2>&1 > /dev/null &
done
