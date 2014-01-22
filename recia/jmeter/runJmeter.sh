#!/bin/sh
 
SCENARIO="~/testPerf/testCas.jmx"
OUTPUT_FILE="output-jmeter.csv"
OUTPUT_DIR="~/testPerf/output"
JMETER="~/testPerf/jakarta-jmeter-2.5/bin/jmeter.sh"

ITER_COUNT=20

pkill -9 java
rm -rf "$OUTPUT_DIR"

# Ramp up by factors of sqrt(2).
# 91 128 181 256 362 512
# 4 8 16 32 64 85 100 128 150
for thread_count in 8 16 32 48 64 80 96 112 128 172
do
	echo "Start run with $thread_count threads."
	$JMETER -n -t $SCENARIO -JnbThreads=$thread_count -JnbIterations=$ITER_COUNT -l "${OUTPUT_DIR}/${thread_count}-${OUTPUT_FILE}"
done

cd "$OUTPUT_DIR/.."
mv "$(basename $OUTPUT_DIR).tgz" "$(basename $OUTPUT_DIR).tgz.bkp"
tar czf "$(basename $OUTPUT_DIR).tgz" "$(basename $OUTPUT_DIR)"

