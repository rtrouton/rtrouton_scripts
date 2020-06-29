#!/bin/bash

# This script performs common tasks using to fix AD binding issues

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Set time server. The NTP server address is being
# passed to the script via Parameter 4.

timeserver="$4"

# Fix network time issues. 

/usr/sbin/ntpdate -u "$timeserver"

# Restart directory services

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then
	/usr/bin/killall DirectoryService
else
	/usr/bin/killall opendirectoryd
fi

# Sleep 30 seconds to allow time for the 
# directory service to come back online

sleep 30
