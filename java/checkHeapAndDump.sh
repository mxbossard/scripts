#!/bin/bash

# Check the Full GC's reclaimed memory to find an anomaly in Heap.

# Search Full GC ifor used memory not freed under 1.400.000 kB in Perm Gen.
egrep ".*PSOldGen: [0-9]{7}K->1[45678][0-9]{5}K.*" logs/gc.log

