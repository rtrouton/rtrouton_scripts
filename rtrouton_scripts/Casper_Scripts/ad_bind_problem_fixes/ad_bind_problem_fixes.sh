#!/bin/bash

# This script performs common tasks using to fix AD binding issues

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Set time server. The NTP server address is being
# passed to the script via Parameter 4.

timeserver="$4"

# Fix network time issues. 

/usr/sbin/ntpdate -u "$timeserver"

# Restart directory services

if [[ ${osvers} -ge 7 ]]; then
	/usr/bin/killall opendirectoryd
else
	/usr/bin/killall DirectoryService
fi

# Sleep 30 seconds to allow time for the 
# directory service to come back online

sleep 30
