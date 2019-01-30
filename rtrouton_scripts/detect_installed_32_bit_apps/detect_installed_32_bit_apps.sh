#!/bin/bash

# Detect all 32-bit apps installed in /Applications, /Library
# or /usr/local and output list to logfile stored in /var/log.


ThirtyTwoBit_app_logfile="/var/log/32bit_apps_installed.log"
ERROR=0

# this script must be run with root privileges
if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then

	# Create log file if not present
	if [[ -f "$ThirtyTwoBit_app_logfile" ]]; then
       echo "$ThirtyTwoBit_app_logfile found. Proceeding..."
	else   
       echo "Creating $ThirtyTwoBit_app_logfile log. Proceeding..."
       touch "$ThirtyTwoBit_app_logfile"
	fi

	# Get a list of all installed applications
	ThirtyTwoBit_app_list=$(/usr/sbin/system_profiler SPApplicationsDataType)

	if [[ -n "$ThirtyTwoBit_app_list" ]]; then

		# get all non-64 Bit applications from the initial list
		ThirtyTwoBit_app_list=$(echo "$ThirtyTwoBit_app_list" | /usr/bin/grep -A3 "64-Bit (Intel): No")

		# filter out all applications in /Applications, /Library and /usr/local
		ThirtyTwoBit_app_list=$(echo "$ThirtyTwoBit_app_list" | /usr/bin/grep -E "Location:[^/]*/(Applications|Library|usr/local)/")

		# remove everything except the path
		ThirtyTwoBit_app_list=$(echo "$ThirtyTwoBit_app_list" | /usr/bin/sed -n 's/.*Location:[[:space:]]*\(.*\)/\1/p')

		if [[ -n "$ThirtyTwoBit_app_list" ]]; then
			echo "$ThirtyTwoBit_app_list" > "$ThirtyTwoBit_app_logfile"
			echo "List of detected applications available in $ThirtyTwoBit_app_logfile"
		else
		    echo "No 32-bit applications found in /Applications, /Library or /usr/local." > "$ThirtyTwoBit_app_logfile"
		fi
	fi

else
	log "ERROR! You must be root in order to run this script!"
	ERROR=1
fi

exit $ERROR