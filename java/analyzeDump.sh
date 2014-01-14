#!/bin/bash 

# Analyse the thread dumps passed in parameter

#set -x

DUMPS="$@"


echo $0

common_nids=( )

for file in $DUMPS
do

	if [ "$file" == "$0" ] 
	then
		continue
	fi



	echo "-------------------- file: $file --------------------"
	echo "Thread count: $(grep "java.lang.Thread.State:" $file | wc -l)"
	echo "Running thread count: $(grep "java.lang.Thread.State: RUNNABLE" $file | wc -l)"
	echo "TP-Processor thread count: $(grep "TP-Processor" $file | wc -l)"
	echo "Bocked thread count: $(grep "java.lang.Thread.State: BLOCKED" $file | wc -l)"
	echo "Waiting for locks:"
	grep "waiting to lock" $file
	echo "uids:"
	egrep -o "F[0-9]{2}[0-9a-z]{5}" $file | sort -u
	
	#echo "Running thread Ids:"
	nids=( $(grep -B1 "java.lang.Thread.State: RUNNABLE" $file | egrep -o "(nid=0x)[0-9a-f]{4,6}") )
	#echo ${nids[*]}
	if [ ${#common_nids[@]} = 0 ]; then
		common_nids=${nids[@]}
	else
		common_nids_str=${common_nids[*]}
		intersect=( )
		for nid in ${nids[@]}; do
  			if [[ $common_nids_str =~ " $nid " ]] ; then    
				# use $nid as regexp
    				intersect+=( $nid )
  			fi
		done
		common_nids=${intersect[@]}
	fi

	echo "Common nids: ${common_nids[*]}"

	echo " "
done
