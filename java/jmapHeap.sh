#!/bin/bash

jmap -heap $(jps | grep Bootstrap | cut -d" " -f1)
