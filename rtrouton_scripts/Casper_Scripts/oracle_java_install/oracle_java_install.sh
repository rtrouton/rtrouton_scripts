#!/bin/bash

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# This script checks the OS of the machine running it
# and triggers the following policies based on OS version
#
# For Macs running 10.7.x - 10.10.x:
#
# Trigger the policy which installs the 
# Oracle Java JRE. These Macs will have
# Apple's Java 6 installed and will only
# need the Oracle Java browser plug-in
#
# For Macs running 10.11.x and later:
#
# Trigger the policy which installs the 
# Oracle Java JDK. These Macs will not have
# Apple's Java 6 installed and will need
# both the Oracle Java browser plug-in and 
# Oracle's system-level Java installed.

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
  echo "Unknown Version Of Mac OS X"
  exit 0
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 7 ]]; then
  echo "Oracle's Java is not available for this version of Mac OS X"
  exit 0
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 7 ]] && [[ ${osvers_minor} -lt 11 ]]; then
  trigger_name="$4"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]]; then
  trigger_name="$5"
fi

if [[ "$trigger_name" != "" ]]; then
  jamf policy -trigger "$trigger_name"
fi
