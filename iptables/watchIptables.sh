#!/bin/sh

OPTS="-v"

#watch -n1 -d "iptables $OPTS -L INPUT > /tmp/output ; iptables $OPTS -L OUTPUT >> /tmp/output ; iptables $OPTS -L FORWARD >> /tmp/output ; iptables $OPTS -L venet-lo >> /tmp/output ; cat /tmp/output"
#watch -n1 -d "iptables $OPTS -L INPUT > /tmp/output ; iptables $OPTS -L FORWARD >> /tmp/output ; iptables $OPTS -L venet-lo >> /tmp/output ; iptables $OPTS -L venet-in >> /tmp/output ; iptables $OPTS -L venet-out >> /tmp/output ; cat /tmp/output"
watch -n1 -d "iptables $OPTS -L INPUT > /tmp/output ; iptables $OPTS -L venet-lo >> /tmp/output ; iptables $OPTS -L venet-in >> /tmp/output ; iptables $OPTS -L venet-out >> /tmp/output ;  iptables $OPTS -L OUTPUT >> /tmp/output ; cat /tmp/output"
