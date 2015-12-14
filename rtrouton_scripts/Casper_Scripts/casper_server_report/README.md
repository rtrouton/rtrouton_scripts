This is a script for Casper servers running on Linux that emails a status report. The script-generated report includes the following:

* Uptime
* Free space on all attached drives
* Who’s logged in via SSH or in the console
* Virtual memory statistics
* Current system tasks
* SMB connections information
* Recent entries in the Apache server logs
* Recent entries in the JSS server log

**Compatibility:**

This script has been tested on the following Linux distributions:

* Red Hat Enterprise Linux 6.x
* CentOS 6.x

**Script location:**

The scripts are stored in **/scripts** on my Casper production and Casper test servers. I created this directory, you can use whatever directory you prefer.

**Crontab:**

The following entry has been added to the root crontab in order to schedule a daily execution of the report script at 10:00 PM:

`0 22 * * * /scripts/casper_server_report.sh 2>&1 >> /dev/null`


**Permissions for the scripts:**

Change permissions on **casper_server_report.sh** to match the following:

* Owner – **root (r/w/x)**
* Group – **wheel (r/x)**
* Everyone **(r/x)**
