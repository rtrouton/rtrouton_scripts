#!/bin/bash

# Detect all Intel apps installed in /Applications, /Library
# or /usr/local and output list to logfile stored in /var/log.

intel_app_logfile="/var/log/intel_apps_installed.log"
ERROR=0

# this script must be run with root privileges
if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then

	# Create log file if not present
	if [[ -f "$intel_app_logfile" ]]; then
       echo "$intel_app_logfile found. Proceeding..."
	else   
       echo "Creating $intel_app_logfile log. Proceeding..."
       touch "$intel_app_logfile"
	fi

	# Get a list of all installed applications
	intel_app_list=$(/usr/sbin/system_profiler SPApplicationsDataType)

	if [[ -n "$intel_app_list" ]]; then

		# get all non-64 Bit applications from the initial list
		intel_app_list=$(echo "$intel_app_list" | /usr/bin/grep -A3 "Intel")

		# filter out all applications in /Applications, /Library and /usr/local
		intel_app_list=$(echo "$intel_app_list" | /usr/bin/grep -E "Location:[^/]*/(Applications|Library|usr/local)/")

		# remove everything except the path
		intel_app_list=$(echo "$intel_app_list" | /usr/bin/sed -n 's/.*Location:[[:space:]]*\(.*\)/\1/p')

		if [[ -n "$intel_app_list" ]]; then
			echo "$intel_app_list" > "$intel_app_logfile"
			echo "List of detected Intel-based applications available in $intel_app_logfile"
		else
		    echo "No Intel-based applications found in /Applications, /Library or /usr/local." > "$intel_app_logfile"
		fi
	fi

else
	log "ERROR! You must be root in order to run this script!"
	ERROR=1
fi

exit $ERROR