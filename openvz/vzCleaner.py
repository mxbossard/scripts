#!/usr/bin/env python  

import math
import subprocess
import socket
import smtplib
from email.mime.text import MIMEText
from datetime import datetime, date, time


# ----- Configuration -----
IGNORED_CTS = [30000]
RCPT_EMAIL = "root@mby.net"
FROM_EMAIL = "root@mby.net"

VZCTL = "/usr/sbin/vzctl"
VZLIST = "/usr/sbin/vzlist"
EXEC = "exec2"

# Fn wich init a CT setup
def initCtSetup( ctId ):
    print "initing setup on CT #%d ..." % ctId
    
    # Install apt-utils
    execVzCmd(ctId, "apt-get -y install apt-utils deborphan")


# Fn which clean a CT
def cleanCt( ctId ):
    print "cleaning CT #%d ..." % ctId
    
    # Remove aptitude & ntp
    execVzCmd(ctId, "apt-get -y remove --purge aptitude ntp")
    
    # Apt cleaning
    execVzCmd(ctId, "apt-get clean")
    execVzCmd(ctId, "apt-get -y autoclean")
    execVzCmd(ctId, "apt-get -y autoremove")
    
    # Clean orphan packages
    execVzCmd(ctId, "apt-get -y remove --purge \"\$(deborphan)\"")

    # Show ct disk space
    execVzCmd(ctId, "df -h /")


# Fn which update & upgrade a CT
def upgradeCt( ctId ):
    print "upgrading CT #%d ..." % ctId
    
    execVzCmd(ctId, "apt-get update")
    execVzCmd(ctId, "apt-get -y upgrade")
    
    
# Fn which secure a CT
def secureCt( ctId ):
    print "securing CT #%d ..." % ctId

    # Lock root user    
    execVzCmd(ctId, "passwd -l root")

    #Remove other execution on some binaries
    execVzCmd(ctId, "[ ! -f /usr/bin/gcc ] || chmod o-x /usr/bin/gcc")
    execVzCmd(ctId, "[ ! -f /usr/bin/make ] || chmod o-x /usr/bin/make")
    execVzCmd(ctId, "[ ! -f /usr/bin/apt-get ] || chmod o-x /usr/bin/apt-get")
    execVzCmd(ctId, "[ ! -f /usr/bin/aptitude ] || chmod o-x /usr/bin/aptitude")
    execVzCmd(ctId, "[ ! -f /usr/bin/dpkg ] || chmod o-x /usr/bin/dpkg")


# ----- Internal vars -----
_recordedReturnCodeMap = {}
_recordedStandardOutputsMap = {}

# Fn which record a command return code perform on a CT
def recordVzOutput( ctId, errorCode, stdout, stderr ):
    codeAbs = math.fabs(errorCode)
    
    # Init error code sum for a CT
    if (ctId not in _recordedReturnCodeMap):
        _recordedReturnCodeMap[ctId] = 0
        _recordedStandardOutputsMap[ctId] = ""

    _recordedReturnCodeMap[ctId] = _recordedReturnCodeMap[ctId] + codeAbs

    output = stdout + "Error code: %d \n" % codeAbs
    if (stderr):
        output = output + "\n########## <ERROR> ##########\n\n" + stderr + "\n########## </ERROR> ##########\n\n"
    output = output + "\n"

    _recordedStandardOutputsMap[ctId] = _recordedStandardOutputsMap[ctId] + output


# Fn which exec a command on a CT 
def execVzCmd( ctId, cmd ):
    command = "%s %s %d %s" % (VZCTL, EXEC, ctId, cmd)
    p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    errorCode = p.wait()
    (stdout, stderr) = p.communicate()
    recordVzOutput(ctId, errorCode, stdout, stderr)


# Fn which return the output of a command performed on a CT
def outputVzCmd( ctId, cmd ):
    command = "%s %s %d %s" % (VZCTL, EXEC, ctId, cmd)
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    return output;


# Fn which retrieve all CT Ids to process
def getCtListToClean():
    ctList = []

    # All CTs  
    output = subprocess.check_output([VZLIST, "-a1"], stderr=subprocess.STDOUT)
    allIds = output.split("\n")

    for id in allIds:
        id = id.strip()
        try:
            id = int(id)
            if (IGNORED_CTS.count(id) == 0):
                ctList.append(id)
        except:
            pass
    
    return ctList


# Execute all actions for a CT
def clean( ctId ):
    initCtSetup(ctId)
    cleanCt(ctId)
    upgradeCt(ctId)
    secureCt(ctId)


# Report the errors
def buildReport():
    report = ""

    # Loop on return code map
    for ctId in _recordedReturnCodeMap:
        if (_recordedReturnCodeMap[ctId] > 0):
            # Errors encountered for this CT
            report += "---------- Standard & Error outputs for CT #%d ----------\n\n" % ctId
            report += _recordedStandardOutputsMap[ctId]

    if (report):
        report = "Errors where encountered while cleanings CTs. \n\n" + report
        print "Errors encountered ! A report was built."

    return report


# Mail the report
def mailReport( report ):
    mailSubject =  "Errors were encoutered while cleaning OpenVz CTs on host %s." % socket.gethostname()
    mailFrom = "OpenVz cleaner tool <%s>" % FROM_EMAIL
    mailTo = RCPT_EMAIL

    if (report):
        msg = MIMEText(report)
        msg["Subject"] = mailSubject
        msg["From"] = mailFrom
        msg["To"] = mailTo

        # Send the message via our own SMTP server, but don't include the
        # envelope header.
        s = smtplib.SMTP('localhost')
        s.sendmail(FROM_EMAIL, RCPT_EMAIL, msg.as_string())
        s.quit()

        print "Email report sent !"

# ----- Script execution -----

now = datetime.now().strftime("%A, %d. %B %Y %H:%M")
print "Start OpenVz cleaner tool on %s" % now

ctToClean = getCtListToClean()

#for ctId in ctToClean:
clean(ctId)

mailReport(buildReport())

# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
