#!/usr/bin/env python

import os
import subprocess

IGNORED_CTS = [30000]

VZCTL = "/usr/sbin/vzctl"
VZLIST = "/usr/sbin/vzlist"

EXEC = "exec2"

# Fn wich init a CT setup
def initCtSetup( ctId ):
    print("initing CT #" + ctId + " ...")
    
    # Install apt-utils
    subprocess.call([VZCTL, EXEC, ctId, "apt-get install apt-utils"])
    subprocess.call([VZCTL, EXEC, ctId, "apt-get install apt-utils"])
    subprocess.call([VZCTL, EXEC, ctId, "apt-get install apt-utils"])


# Fn which clean a CT
def cleanCt( ctId ):
    print("cleaning CT #" + ctId + " ...")
    
    # Clean orphan packages
    subprocess.call([VZCTL, EXEC, ctId, "apt-get -y install deborphan ; apt-get -y remove --purge `deborphan`"])

    # Remove aptitude & ntp
    subprocess.call([VZCTL, EXEC, ctId, "apt-get -y remove --purge aptitude ntp"])
    
    # Apt cleaning
    subprocess.call([VZCTL, EXEC, ctId, "apt-get clean"])
    subprocess.call([VZCTL, EXEC, ctId, "apt-get -y autoclean"])
    subprocess.call([VZCTL, EXEC, ctId, "apt-get -y autoremove"])
    
    # Show ct disk space
    subprocess.call([VZCTL, EXEC, ctId, "df -h /"])


# Fn which update & upgrade a CT
def upgradeCt( ctId ):
    print("upgrading CT #" + ctId + " ...")
    
    subprocess.call([VZCTL, EXEC, ctId, "apt-get update"])
    subprocess.call([VZCTL, EXEC, ctId, "apt-get -y upgrade"])
    
    
# Fn which secure a CT
def secureCt( ctId ):
    print("securing CT #"+ ctId + " ...")

    # Lock root user    
    subprocess.call([VZCTL, EXEC, ctId, "passwd -l root"])

    #Remove other execution on some binaries
    subprocess.call([VZCTL, EXEC, ctId, "test -f /usr/bin/gcc && chmod o-x /usr/bin/gcc"])
    subprocess.call([VZCTL, EXEC, ctId, "test -f /usr/bin/make && chmod o-x /usr/bin/make"])
    subprocess.call([VZCTL, EXEC, ctId, "test -f /usr/bin/apt-get && chmod o-x /usr/bin/apt-get"])
    subprocess.call([VZCTL, EXEC, ctId, "test -f /usr/bin/aptitude && chmod o-x /usr/bin/aptitude"])
    subprocess.call([VZCTL, EXEC, ctId, "test -f /usr/bin/dpkg && chmod o-x /usr/bin/dpkg"])


# Fn which retrieve all CT Ids to process
def getCtListToClean():
    ctList = []
    
    # All CTs  
    p = subprocess.Popen([VZLIST, "-a1"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    #output = subprocess.check_output(VZLIST + " -a1 | tr -d ' '", stderr=subprocess.STDOUT)
    #output = os.popen(VZLIST + " -a1 | tr -d ' '")
    #output = os.popen(VZLIST + " -a1")
    (output, err) = p.communicate()

#    print output.split("\n")

#    while (id = output.readLine()) != '':
#        print id.strip()

    allIds = output.split("\n")

    for id in allIds:
        id = id.strip()
        print "id: %s" % id
        id = int(id)
        print "id: #%d" % id
        if (IGNORED_CTS.count(id) == 0):
        	ctList.append(id)
    
	return ctList


print(getCtListToClean())

