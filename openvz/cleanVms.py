#!/usr/bin/env python

import os
import subprocess

IGNORED_CTS = [30000]

VZCTL = "/usr/sbin/vzctl"

EXEC = " exec2 "

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
    p = subprocess.call(VZLIST + " -a1", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, err) = p.communicate()
    
    for id in output:
        ctList.add(id)

    ctList.removeAll(IGNORED_CTS)
    
    return ctList

    print(getCtListToClean())

