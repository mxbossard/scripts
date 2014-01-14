#!/bin/bash

jmap -histo $(jps | grep Bootstrap | cut -d" " -f1) > /tmp/jmap_histo.txt

