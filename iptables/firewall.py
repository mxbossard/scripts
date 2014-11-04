#!/usr/bin/env python

import ConfigParser
import math
import subprocess
from datetime import datetime, date, time
import re

CONFIG_FILE = "sample.cfg"

IPT_CMD = "/sbin/iptables"

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
	_name=""
	_chain=""
	_prot=""
	_srcIface=""
	_srcIp=""
	_srcPort=""
	_dstIface=""
	_dstIp=""
	_dstPort=""

	def map(self, config, section, ruleName):
		self._name = ruleName

		if config.has_option(section, ruleName + ".chain"):
			self._chain = config.get(section, ruleName + ".chain")
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
	
	def appendIptablesRule(self):
                return "%s -A %s %s" % (IPT_CMD, self._chain, self.iptablesRule())

	def insertIptablesRule(self, index):
                return "%s -I %s %d %s" % (IPT_CMD, self._chain, index, self.iptablesRule())

        def delIptablesRule(self):
                return "%s -D %s %s" % (IPT_CMD, self._chain, self.iptablesRule())

class FilterRule(AbstractRule):
	_target=""

	def map(self, config, section, ruleName):
		AbstractRule.map(self, config, section, ruleName)
		target = config.get(section, ruleName + ".target")
		if target:
			self._target = target

	def iptablesRule(self):
		target=""
                prot=""
                srcIp=""
                srcPort=""
                srcIface=""
                dstIp=""
                dstPort=""
                dstIface=""

                if (not self._chain):
                        raise Exception("Chain need to be set in filter rule %s !" % self._name)
                if (not self._target):
                        raise Exception("Target need to be set in filter rule %s !" % self._name)

                if (self._target):
                        target = "-j %s" % self._target
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

                rule = "-t nat %s %s %s %s %s %s %s %s %s" % (prot, self.getMatchOpt(), srcIp, srcPort, srcIface, dstIp, dstPort, dstIface, target)
                rule = re.sub(' +', ' ', rule)

                return rule



class DnatRule(AbstractRule):
	_chain="PREROUTING"
	_dnatDst=""

	def map(self, config, section, ruleName):
		AbstractRule.map(self, config, section, ruleName)
		dst = config.get(section, ruleName + ".dnat.dst")
		if dst:
			self._dnatDst = dst

	def iptablesRule(self):
		prot=""
		srcIp=""
		srcPort=""
		srcIface=""
		dstIp=""
		dstPort=""
		dstIface=""

		if (not self._dnatDst):
			raise Exception("DNAT destination need to be set in dnat rule: %s !" % self._name)

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
			
		rule = "-t nat -j DNAT %s %s %s %s %s %s %s %s" % (prot, self.getMatchOpt(), srcIp, srcPort, srcIface, dstIp, dstPort, dstIface)
		rule = re.sub(' +', ' ', rule)

		return rule



def parseRulesNames (config, section):
	if (not config.has_section(section)):
		return []

	options = config.options(section)
	options.sort()

	rulesNames = set([])
	for option in options:
		rulesNames.add(option.split(".")[0])
	
	return rulesNames


SECTIONS_CONFIG = {"dnat" : DnatRule, "filter" : FilterRule}

config = ConfigParser.SafeConfigParser()
config.read(CONFIG_FILE)

rules = []

for section, ruleType in SECTIONS_CONFIG.iteritems():

	rulesNames = parseRulesNames(config, section)
	print "section: %s ; rules: %s" % (section, rulesNames)
	for ruleName in rulesNames:
		rule = ruleType()
		rule.map(config, section, ruleName)
		rules.append(rule)

for rule in rules:
	print rule.delIptablesRule()
	print rule.appendIptablesRule()
	print rule.insertIptablesRule(1)



	
# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
