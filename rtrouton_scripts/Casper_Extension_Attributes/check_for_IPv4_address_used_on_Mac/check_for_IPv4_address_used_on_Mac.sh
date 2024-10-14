#!/bin/bash

# This Jamf Pro Extension attribute detects if an IPv4 network address is being used
# on a Mac. It returns the value below if one or more IPv4 addresses are detected on
# the Mac's various network interfaces.
#
# 1
#
# In all other cases, the value below is returned:
#
# 0

IPv4Detected=$(/usr/sbin/system_profiler SPNetworkDataType | /usr/bin/grep -c "IPv4 Addresses:")

eaResult="0"

if [[ "$IPv4Detected" -ge 1 ]]; then 
    eaResult="1"
fi

echo "<result>$eaResult</result>"