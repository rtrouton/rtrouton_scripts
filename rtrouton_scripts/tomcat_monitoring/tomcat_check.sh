#!/bin/bash
# Services Restarter - Automatically restart tomcat if it dies
/bin/netstat -ln | /bin/grep ":8080 " | /usr/bin/wc -l | /bin/awk '{if ($1 == 0) system("/scripts/tomcat_report.sh; /etc/rc.d/init.d/jamf.tomcat7 stop; /etc/rc.d/init.d/jamf.tomcat7 start") }'
