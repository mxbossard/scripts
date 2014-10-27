#!/usr/bin/env python

import ConfigParser
import math
import subprocess
from datetime import datetime, date, time
import re

CONFIG_FILE="sample.cfg"

IPT_CMD="/sbin/iptables"
DNAT_SECTION="dnat"

# Fn which exec a command
def execCmd( cmd ):
	p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	errorCode = p.wait()
	(stdout, stderr) = p.communicate()
	return (errorCode, stdout, stderr)

# Fn which return the output of a command
def outputCmd( cmd ):
	output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
	return output;

def addDNatRule (  ):
	print "foo"

class AbstractRule:
	_prot=""
	_srcIface=""
	_srcIp=""
	_srcPort=""
	_dstIface=""
	_dstIp=""
	_dstPort=""

	def map(self, section, config, ruleName):
		if config.has_option(section, ruleName + ".prot"):
			self._prot = config.get(section, ruleName + ".prot")
		if config.has_option(section, ruleName + ".src.iface"):
			self._srcIface = config.get(section, ruleName + ".src.iface")
		if config.has_option(section, ruleName + ".src.ip"):
			self._srcIp = config.get(section, ruleName + ".src.ip")
		if config.has_option(section, ruleName + ".src.port"):
			self._srcPort = config.get(section, ruleName + ".src.port")
		if config.has_option(section, ruleName + ".dst.iface"):
			self._dstIface = config.get(section, ruleName + ".dst.iface")
		if config.has_option(section, ruleName + ".dst.ip"):
			self._dstIp = config.get(section, ruleName + ".dst.ip")
		if config.has_option(section, ruleName + ".dst.port"):
			self._dstPort = config.get(section, ruleName + ".dst.port")

	def getMatchOpt(self):
		matchOpt = ""

		if ("," in self._srcPort or "," in self._dstPort):
			matchOpt += " multiport"

		if (matchOpt):
			matchOpt = "--match" + matchOpt

		return matchOpt

	def iptablesRule(self):
		raise Exception("Need to override iptablesRule() !")


class DnatRule(AbstractRule):
	_dnatDst=""
	
	def map(self, config, ruleName):
		AbstractRule.map(self, DNAT_SECTION, config, ruleName)
		if config.has_option(DNAT_SECTION, ruleName + ".dnat.dst"):
			self._dnatDst = config.get(DNAT_SECTION, ruleName + ".dnat.dst")

	def iptablesRule(self):
		prot=""
		srcIp=""
		srcPort=""
		srcIface=""
		dstIp=""
		dstPort=""
		dstIface=""

		if (not self._dnatDst):
			raise Exception("DNAT destination need to be set !")

		if (self._prot):
			srcIp = "-p %s" % self._prot
		if (self._srcIp):
			srcIp = "-s %s" % self._srcIp
		if (self._srcPort):
			srcPort = "--sport %s" % self._srcPort
		if (self._srcIface):
			srcIface = "-i %s" % self._srcIface
		if (self._dstIp):
			dstIp = "-d %s" % self._dstIp
		if (self._dstPort):
			dstPort = "--dport %s" % self._dstPort
		if (self._dstIface):
			dstIface = "-o %s" % self._dstIface
			
		rule = "-t nat -j DNAT %s %s %s %s %s %s %s %s --to-destination %s" % (prot, self.getMatchOpt(), srcIp, srcPort, srcIface, dstIp, dstPort, dstIface, self._dnatDst)
		rule = re.sub(' +', ' ', rule)

		return rule

	def appendIptablesRule(self):
		return "%s %s %s" % (IPT_CMD, "-A PREROUTING", self.iptablesRule())

	def delIptablesRule(self):
		return "%s %s %s" % (IPT_CMD, "-D PREROUTING", self.iptablesRule())	


def parseRulesNames (config, section):
	if (not config.has_section(section)):
		return []

	options = config.options(section)
	options.sort()

	rulesNames = set([])
	for option in options:
		rulesNames.add(option.split(".")[0])
	
	return rulesNames


config = ConfigParser.SafeConfigParser()
config.read(CONFIG_FILE)

dnatRulesNames = parseRulesNames(config, DNAT_SECTION)

dnatRules = []
for ruleName in dnatRulesNames:
	rule = DnatRule()
	rule.map(config, ruleName)
	dnatRules.append(rule)


for dnatRule in dnatRules:
	print dnatRule.delIptablesRule()
	print dnatRule.appendIptablesRule()



	
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
