#!/bin/sh 
PATH=/bin:/usr/bin:/sbin:/usr/sbin export PATH 

# This mini shell script will read your logs, output the information to a text file, 
# and then mail the output to an email address. 
# This originally was in an AFP548.com server setup guide, which you can download
# from http://www.afp548.com/filemgmt/visit.php?lid=68 (written by Corey Carson).
# I've taken the script and edited it, smartening it up to make it portable.
# Basically, it reads your logs, outputs it to a file, and shoots the file over to you via email.
# Use at your own risk; there are no guarantees with this script.  
# Noah Abrahamson -- nbfa@stanford.edu; March 19th, 2008
#
# Modified by Rich Trouton - rtrouton@mail.nih.gov; January 14th 2008
# Following sections added to original script: "CURRENTLY ESTABLISHED SSH AND CONSOLE CONNECTIONS",  "AFP STATUS", "SMB STATUS",
# "ATTEMPTED UNAUTHORIZED SUDO USE", "AUTHORIZED SUDO USE"
# Sections modified from original script: "UNSUCCESSFUL ATTEMPTS TO LOGIN VIA SSH"
# Sections removed from original script (don't use Tivoli or rsync for backups): "TSM DAILY BACKUP TRANSFER", "RSYNC TRIGGER FILE"
#
#
# Modified by Rich Trouton - richtrouton@mac.com; August 1st 2010
# Following sections added to original script: "TIME MACHINE ACTIVITY"
#
# Modified by Rich Trouton - richtrouton@mac.com; April 28, 2011
# Sections modified from previous script: "TIME MACHINE ACTIVITY"
# Added system.log checking for both the 10.5 and 10.6 backupd processes
# For 10.5, it checks for /System/Library/CoreServices/backupd
# For 10.6, it checks for com.apple.backupd
#
# Modified by Rich Trouton - richtrouton@mac.com; April 29, 2011
# Following sections added to original script: CHECK APPLE RAID
# Added checking for G5s and Intel Macs that may have hardware RAID cards
# installed. If the G5 or Intel Mac has a RAID card installed, the status is
# reported. Otherwise returns that there's no hardware RAID card installed. If
# Mac is not a G5 or an Intel Mac, section will add nothing to the email report
#
#

# Define the recipient.
RECIP="your_email@example.com"


# That should be it for the necessary configuration part. The rest can be pretty much as-is.
NAME=`networksetup -getcomputername`
LOGS="/private/tmp/daily-report.txt"
SWUD="/private/tmp/daily-report-softwareupdatelist.txt"
RAIDLOG="/private/tmp/raid-status.txt"
AFPLOG="/private/tmp/afp-status.txt"
SMBLOG="/private/tmp/smb-status.txt"
HWLOGDATE=$(printf "`date "+%a %h %e"` \n")
SEND="daily_report@`hostname`"

# Let's determine the IP address.
# We have to do this a number of different ways. ifconfig is unreliable
# when you have lots of different hardware models,
# and because there are different numbering schemes.
# One of these will set the ADDY variable correctly

ADDY=`networksetup -getinfo Built-in\ Ethernet\ 1 | grep "^IP\ " | cut -c 13-26`
if [ -z $ADDY ]; then ADDY=`networksetup -getinfo Airport | grep "^IP\ " | cut -c 13-26`; fi
if [ -z $ADDY ]; then ADDY=`networksetup -getinfo Wi-Fi | grep "^IP\ " | cut -c 13-26`; fi
if [ -z $ADDY ]; then ADDY=`networksetup -getinfo Built-in\ Ethernet | grep "^IP\ " | cut -c 13-26`; fi    
if [ -z $ADDY ]; then ADDY=`networksetup -getinfo Ethernet | grep "^IP\ " | cut -c 13-26`; fi
if [ -z $ADDY ]; then ADDY=`networksetup -getinfo Ethernet\ 1 | grep "^IP\ " | cut -c 13-26`; fi


# Now begin writing the daily report.
echo "From: Daily Report Robot <$SEND>" > $LOGS 
echo "To: $RECIP" >> $LOGS 
echo "Subject: $NAME daily report" - `date` >> $LOGS 
    
# Give an introduction.
echo "***********************************************************************" >> $LOGS
echo "***** Hello. This is the daily report for `date "+%a %h %e"`. " >> $LOGS
echo "***** This is for `hostname` ($ADDY). " >> $LOGS
echo "***********************************************************************" >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS

# Check the uptime, so we can notice any unexpected and automatic reboots.
echo "Uptime" >> $LOGS 
echo "------" >> $LOGS 
echo `uptime` >> $LOGS 
echo " " >> $LOGS
echo " " >> $LOGS  


# Check to see how much space we have left on the volumes.
echo "FREE SPACE" >> $LOGS 
echo "----------" >> $LOGS 
df -khl >> $LOGS 
echo " " >> $LOGS 
echo " " >> $LOGS 


# This looks at who's connected at the time of this report's generation.
# It's probably not too interesting. We have to filter for this host's IP
# address because it might be a syslog server and the logs would be cluttered.
echo "CURRENTLY ESTABLISHED CONNECTIONS" >> $LOGS 
echo "---------------------------------" >> $LOGS 
netstat -an | grep -i "established" | grep $ADDY >> $LOGS 
echo " " >> $LOGS 
echo " " >> $LOGS 

# This looks at who's connected via SSH or at the console at the time of this report's generation.
echo "CURRENTLY ESTABLISHED SSH AND CONSOLE CONNECTIONS" >> $LOGS
echo "-------------------------------------------------" >> $LOGS
who >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS


# This looks at whether AFP is running and who is connected via AFP at the time of this report's generation.
echo "AFP STATUS" >> $LOGS
echo "-------------------" >> $LOGS
# Checks if AFP services are currently running. If they are, it pulls a
# list of the current connections. If not, it reports that AFP services are
# not running.
serveradmin command afp:command = getConnectedUsers >> $AFPLOG
if grep -iE 'afp:state = "RUNNING"' $AFPLOG
then
    if grep -iE 'afp:usersArray = _empty_array' $AFPLOG
       then
         echo "AFP Services Running." >> $LOGS
         echo " " >> $LOGS
         echo "No AFP Users Connected." >> $LOGS
         echo " " >> $LOGS
         echo " " >> $LOGS
       else
         echo "AFP Services Running." >> $LOGS
         echo " " >> $LOGS
         echo "Current AFP Users" >> $LOGS
         echo "(Check the array_index number to match users with the IP they're connecting from.)" >> $LOGS
         echo " " >> $LOGS
# The next two report functions use /usr/sbin/serveradmin to get a list of connected users and the IPs they're connecting from. Each will have a unique array index number, which can be used to match
# reported usernames with the IP they're connecting from.
         serveradmin command afp:command = getConnectedUsers | grep -iE "name" >> $LOGS
         echo " " >> $LOGS
         serveradmin command afp:command = getConnectedUsers | grep -iE "ipAddress" >> $LOGS
         echo " " >> $LOGS
         echo " " >> $LOGS
     fi
#    serveradmin command afp:command = getConnectedUsers >> $LOGS
#    echo " " >> $LOGS
#    echo " " >> $LOGS
else
    echo "AFP Services Not Running." >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
fi


# This looks at whether SMB is running and who is connected via SMB at the time of this report's generation.
echo "SMB STATUS" >> $LOGS
echo "-------------------" >> $LOGS 
# Checks if SMB services are currently running. If they are, it pulls a 
# list of the current connections. If not, it reports that SMB services are
# not running.
serveradmin command smb:command = getConnectedUsers >> $SMBLOG
if grep -iE 'smb:state = "RUNNING"' $SMBLOG
then
    if grep -iE 'smb:usersArray = _empty_array' $SMBLOG
       then
         echo "SMB Services Running." >> $LOGS
         echo " " >> $LOGS
         echo "No SMB Users Connected." >> $LOGS
         echo " " >> $LOGS
         echo " " >> $LOGS
       else
         echo "SMB Services Running." >> $LOGS
         echo " " >> $LOGS
         echo "Current SMB Users" >> $LOGS
         echo "(Check the array_index number to match users with the IP they're connecting from.)" >> $LOGS
         echo " " >> $LOGS
# The next two report functions use /usr/sbin/serveradmin to get a list of connected users and the IPs they're connecting from. Each will have a unique array index number, which can be used to match
# reported usernames with the IP they're connecting from.
         serveradmin command smb:command = getConnectedUsers | grep -iE "name" >> $LOGS
         echo " " >> $LOGS
         serveradmin command smb:command = getConnectedUsers | grep -iE "ipAddress" >> $LOGS
         echo " " >> $LOGS
         echo " " >> $LOGS
     fi
else
    echo "SMB Services Not Running." >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
fi

# This test if for attempts to connect via SSH by bad people.
echo "UNSUCCESSFUL ATTEMPTS TO LOGIN VIA SSH" >> $LOGS
echo "---------------------" >> $LOGS
if grep -iE 'failed|invalid' /var/log/secure.log | grep "sshd\[" > /dev/null
then
    grep -iE 'failed|invalid' /var/log/secure.log | grep "sshd" | grep -v "system.login.tty" | grep -v "bsm_audit_session_setup" >> $LOGS
    echo " " >> $LOGS
    echo "If there's nothing above this line, but you're not seeing the All Clear message, there were SSH errors logged in /var/log/secure.log that didn't trip the alarm notifications for this report." >> $LOGS
    echo " " >> $LOGS 
    echo " " >> $LOGS
else
    echo "All's clear on the Western Front." >> $LOGS
    echo " " >> $LOGS 
    echo " " >> $LOGS
fi

# This checks for attempts to run sudo by users without sudo rights.
echo "ATTEMPTED SUDO USE" >> $LOGS
echo "---------------------" >> $LOGS
if grep -E 'NOT' /var/log/system.log | grep "sudo" > /dev/null
then
    grep -E 'NOT' /var/log/system.log | grep "sudo" | grep "NOT" >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
else
    echo "All's clear on the Western Front." >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
fi

# This checks for authorized sudo commands.
echo "AUTHORIZED SUDO USE" >> $LOGS
echo "---------------------" >> $LOGS
if grep -E 'COMMAND' /var/log/system.log | grep "sudo" > /dev/null
then
    grep -E 'COMMAND' /var/log/system.log | grep "sudo" | grep -v "NOT" >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
else
    echo "All's clear on the Western Front." >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
fi


# This checks for Time Machine backup commands.
echo "TIME MACHINE ACTIVITY" >> $LOGS
echo "---------------------" >> $LOGS
if grep -E 'com.apple.backupd' /var/log/system.log | grep "backup" > /dev/null; then
    grep -E 'com.apple.backupd' /var/log/system.log | grep "backup" >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
elif grep -E '/System/Library/CoreServices/backupd' /var/log/system.log | grep "backup" > /dev/null; then
    grep -E '/System/Library/CoreServices/backupd' /var/log/system.log | grep "backup" >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
else
    echo "Time Machine backups not running." >> $LOGS
    echo " " >> $LOGS
    echo " " >> $LOGS
fi

#Check Apple RAID Condition

if [ `machine` = "ppc970" ]; then
echo "APPLE HARDWARE RAID STATUS" >> $LOGS
echo "-----------------" >> $LOGS 
megaraid -showdevices >> $RAIDLOG 
	if grep -iE 'No MegaRAID Adapter Available' $RAIDLOG; then
    		echo "Apple RAID card for G5 XServes not installed."  >> $LOGS
		echo " " >> $LOGS
		echo " " >> $LOGS		
	else
		megaraid -showdevices >> $LOGS
		echo " " >> $LOGS
		echo " " >> $LOGS
	fi
fi

if [ `machine` = "i486" ]; then
echo "APPLE HARDWARE RAID STATUS" >> $LOGS
echo "-----------------" >> $LOGS 
system_profiler SPHardwareRAIDDataType >> $RAIDLOG 
	if grep -iE 'Hardware RAID' $RAIDLOG; then
    		system_profiler SPHardwareRAIDDataType >> $LOGS
		echo " " >> $LOGS
		echo " " >> $LOGS
	else
		echo "Apple RAID card for Intel Macs not installed." >> $LOGS
		echo " " >> $LOGS
		echo " " >> $LOGS

	fi
fi

# This one checks for Xserve hardware monitoring logs.
# Note that we need to quote-out the variable because it contains spaces.
if [ -f /var/log/hwmond.log ]; then    
    echo "HARDWARE MONITOR EVENTS" >> $LOGS
    echo "-----------------------" >> $LOGS
    grep "$HWLOGDATE" /var/log/hwmond.log >> $LOGS
    echo " " >> $LOGS 
    echo " " >> $LOGS
fi


# Look for Software Updates. Only the ones with asterisks will be noted.
# These are ones that haven't been set to be ignored.
echo "AVAILABLE SOFTWARE UPDATES" >> $LOGS
echo "--------------------------" >> $LOGS
softwareupdate -l | grep \* > $SWUD
if cat $SWUD | wc -l > /dev/null
then 
    cat $SWUD >> $LOGS
else 
    echo "No recommended updates at this time." >> $LOGS
fi
echo " " >> $LOGS 
echo " " >> $LOGS



# Read LOGS, pipe it to sendmail and fire off an email.
cat $LOGS | sendmail -f $RECIP -t

# Get rid of the files.
rm $LOGS
rm $RAIDLOG
rm $SWUD
rm $AFPLOG
rm $SMBLOG
