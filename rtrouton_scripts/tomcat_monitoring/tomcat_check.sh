#!/bin/bash

# Identify Tomcat startup script
if [[ -f /etc/rc.d/init.d/jamf.tomcat7 ]]; then
    tomcat_startup_script=/etc/rc.d/init.d/jamf.tomcat7
elif [[ -f /etc/rc.d/init.d/jamf.tomcat8 ]]; then
    tomcat_startup_script=/etc/rc.d/init.d/jamf.tomcat8
fi

# Services Restarter - Automatically restart tomcat if it dies
/bin/netstat -ln | /bin/grep ":8080 " | /usr/bin/wc -l | /bin/awk '{if ($1 == 0) system("/scripts/tomcat_report.sh; '$tomcat_startup_script' stop; '$tomcat_startup_script' start") }'