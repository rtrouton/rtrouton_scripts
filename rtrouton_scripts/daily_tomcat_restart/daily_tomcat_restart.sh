#!/bin/bash

# Services Restarter - Restarts the JAMF Tomcat installation

# Stop the JAMF Tomcat processes

if [[ -f /etc/rc.d/init.d/jamf.tomcat7 ]]; then
    /etc/rc.d/init.d/jamf.tomcat7 stop
elif [[ -f /etc/rc.d/init.d/jamf.tomcat8 ]]; then
    /etc/rc.d/init.d/jamf.tomcat8 stop
fi

# Wait 10 seconds for Tomcat process to fully stop

sleep 10

# Starts the JAMF Tomcat processes

if [[ -f /etc/rc.d/init.d/jamf.tomcat7 ]]; then
    /etc/rc.d/init.d/jamf.tomcat7 start
elif [[ -f /etc/rc.d/init.d/jamf.tomcat8 ]]; then
    /etc/rc.d/init.d/jamf.tomcat8 start
fi