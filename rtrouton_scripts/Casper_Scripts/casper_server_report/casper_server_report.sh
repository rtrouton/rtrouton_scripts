#!/bin/sh 
PATH=/bin:/usr/bin:/sbin:/usr/sbin export PATH

# Define the recipient.
RECIP="email_address@domain.name.here"

# That should be it for the necessary configuration part. The rest can be pretty much as-is.
NAME=`hostname`
LOGS="/tmp/casper_server_report.txt"
HWLOGDATE=$(printf "`date "+%a %h %e"` \n")
SEND="casper_server_report@`hostname`"

# Now begin writing the daily report.
echo "From: Casper Server Report <$SEND>" > $LOGS 
echo "To: $RECIP" >> $LOGS 
echo "Subject: $NAME Casper Server Report" - `date` >> $LOGS 

ADDY=`ifconfig eth1 |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}'`

    
# Give an introduction.
echo "***********************************************************************" >> $LOGS
echo "***** Hello. This is the Casper server report for `date "+%a %h %e"`. " >> $LOGS
echo "***** Report is for `hostname` ($ADDY). " >> $LOGS
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

# This reports on the virtual memory stats
echo "REPORT VIRTUAL MEMORY STATISTICS" >> $LOGS
echo "--------------------------------" >> $LOGS
vmstat 1 10 >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS

# This reports on the list of tasks currently being managed by the operating system
echo "REPORT CURRENT SYSTEM TASKS" >> $LOGS
echo "--------------------------------" >> $LOGS
top -n 1 -b > /tmp/top-output.txt && less /tmp/top-output.txt >> $LOGS && rm /tmp/top-output.txt
echo " " >> $LOGS
echo " " >> $LOGS

# This reports on who is connected via SMB.
echo "SMB STATUS" >> $LOGS
echo "-------------------" >> $LOGS 
smbstatus -v >> $LOGS 
echo " " >> $LOGS
echo " " >> $LOGS

# This tails /var/log/httpd/access_log to 
# provide a view of recent activity.
echo "LAST 200 LINES OF THE APACHE SERVER LOG" >> $LOGS
echo "--------------------------------" >> $LOGS
tail -200 /var/log/httpd/access_log  >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS


# This tails /local/jss/logs/JAMFSoftwareServer.log
# provide a view of recent activity.
echo "LAST 200 LINES OF THE JSS SERVER LOG" >> $LOGS
echo "--------------------------------" >> $LOGS
tail -200 /usr/local/jss/logs/JAMFSoftwareServer.log  >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS

# Read LOGS, pipe it to sendmail and fire off an email.
cat $LOGS | sendmail -f $RECIP -t

# Get rid of the files.
rm $LOGS
