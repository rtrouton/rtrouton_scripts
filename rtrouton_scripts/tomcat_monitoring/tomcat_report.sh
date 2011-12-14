#!/bin/sh 
PATH=/bin:/usr/bin:/sbin:/usr/sbin export PATH 

# Define the recipient.
RECIP="email@address.here"

# That should be it for the necessary configuration part. The rest can be pretty much as-is.
NAME=`hostname`
LOGS="/tmp/tomcat-restart.txt"
HWLOGDATE=$(printf "`date "+%a %h %e"` \n")
SEND="tomcat_restart@`hostname`"

# Now begin writing the daily report.
echo "From: Tomcat Restart Report <$SEND>" > $LOGS 
echo "To: $RECIP" >> $LOGS 
echo "Subject: $NAME Tomcat Restart Report" - `date` >> $LOGS 

ADDY=`ifconfig eth1 |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}'`

    
# Give an introduction.
echo "***********************************************************************" >> $LOGS
echo "***** Hi. You're receiving this because Tomcat restarted"  >> $LOGS
echo "***** This is the report for `date "+%a %h %e"`. " >> $LOGS
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

# This reports on the virtual memory stats at the time of the stoppage
echo "REPORT VIRTUAL MEMORY STATISTICS" >> $LOGS
echo "--------------------------------" >> $LOGS
vmstat 1 10 >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS

# This tails /usr/local/jss/logs/JAMFSoftwareServer.log and hopefully catches the error
echo "LAST 60 LINES OF THE JSS SERVER LOG" >> $LOGS
echo "--------------------------------" >> $LOGS
tail -60 /usr/local/jss/logs/JAMFSoftwareServer.log  >> $LOGS
echo " " >> $LOGS
echo " " >> $LOGS

# Read LOGS, pipe it to sendmail and fire off an email.
cat $LOGS | sendmail -f $RECIP -t

# Get rid of the files.
rm $LOGS
