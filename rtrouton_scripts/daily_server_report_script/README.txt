One of the items that I’ve found and adapted for my own use over the past couple of years has been a script for my servers that emails me a status report on a daily basis. The script tells me a number of things that are good to know, including the following:

Uptime
Free space on all attached drives
Who’s logged in via SSH or in the console (console = logged in via Login Window)
If AFP is running, and who is logged in via AFP
If SMB is running, and who is logged in via SMB
Unsuccessful login attempts via SSH
Unsuccessful attempts to use sudo by accounts not authorized to use sudo
Authorized sudo commands that have been run
Time Machine backup status (10.5.x and higher only)
Apple Hardware RAID status
XServe hardware monitoring messages
Any available software updates

More background here: http://derflounder.wordpress.com/2010/08/31/daily-server-reports/

Permissions for the scripts:

For 10.4.x:

In /etc/periodic/daily: copy 090.daily.logreport to /etc/periodic/daily

Change permissions on /etc/periodic/daily/090.daily.logreport to match the following:

Owner – root (r/w/x)
Group – wheel (r/x)
Everyone – (r/x)


For 10.5.x and higher:

In /Library/LaunchDaemons: copy com.company.daily_report.plist to /Library/LaunchDaemons

Change permissions on /Library/LaunchDaemons/com.company.daily_report.plist to match the following:

Owner – root (r/w)
Group – wheel (r)
Everyone – (r)
In /Library/: Copy the directory called daily_report_script to /Library. It has a script inside called daily_logreport.sh that generates and emails the nightly report.

Change permissions to match the following:
/Library/daily_report_script/

Owner – root (r/w/x)
Group – admin (r/w/x)
Everyone – (r/x)
/Library/daily_report_script/daily_logreport.sh

Owner – root (r/w/x)
Group – wheel (r/x)
Everyone – (r/x)