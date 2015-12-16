#!/bin/bash

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
  echo "<result>Unknown Version of Mac OS X</result>"
fi

# Checks to see if the OS on the Mac is 10.11.x or higher.
# If it is not, the following message is displayed without quotes:
#
# "System Integrity Protection Not Available For" followed by the version of OS X.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 11 ]]; then
  echo "<result>System Integrity Protection Not Available For `sw_vers -productVersion`</result>"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]]; then
 
# Checks System Integrity Protection status on Macs
# running 10.11.x or higher

  SIP_status=`/usr/bin/csrutil status | awk '/status/ {print $5}' | sed 's/\.$//'`

  if [ $SIP_status = "disabled" ]; then
      result=Disabled
  elif [ $SIP_status = "enabled" ]; then
      result=Active
  fi
   echo "<result>$result</result>"
fi