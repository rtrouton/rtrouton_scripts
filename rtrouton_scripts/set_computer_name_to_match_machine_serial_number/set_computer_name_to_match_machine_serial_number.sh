#!/bin/bash

# Sets the computer name to the machine's serial number. 
#
# If the Jamf agent is installed, the script uses the Jamf agent to set
# the computer name to the machine's serial number.
#
# If the Jamf agent is not installed, the scutil command line tool is used.

jamfAgentPath="/usr/local/jamf/bin/jamf"

if [[ -x "$jamfAgentPath" ]]; then
	"$jamfAgentPath" setComputerName -useSerialNumber
else
	machineSerial=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4; }')

	if [[ -n "$machineSerial" ]]; then	
		/usr/sbin/scutil --set ComputerName "$machineSerial"
		/usr/sbin/scutil --set LocalHostName "$machineSerial"
		/usr/sbin/scutil --set HostName "$machineSerial"
	fi
fi

exit 0