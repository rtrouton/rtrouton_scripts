#!/bin/bash

# Detect all Intel apps installed in /Applications, /Library
# or /usr/local and output list to logfile stored in /var/log.

intel_app_logfile="/var/log/intel_apps_installed.log"
ERROR=0

# Check for the jq command line tool to be installed. It must be installed for this script to work.
# The jq command line tool is installed by default on macOS Sequoia and later. 

which jq &>/dev/null

if [[ $? -ne 0 ]]; then
   echo "ERROR: jq command line tool is not installed. Please install the jq command line tool."
   echo "Downloads available from https://jqlang.org/download/ ."
   ERROR=1
   exit "$ERROR"
fi

# this script must be run with root privileges
if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then

	# Create log file if not present
	if [[ -f "$intel_app_logfile" ]]; then
       echo "$intel_app_logfile found. Proceeding..."
	else
       echo "Creating $intel_app_logfile log. Proceeding..."
       touch "$intel_app_logfile"
	fi

	# Get a list of all installed applications exported to JSON format
	intel_app_list=$(/usr/sbin/system_profiler SPApplicationsDataType -json)

	if [[ -n "$intel_app_list" ]]; then

		# Filter to apps whose arch_kind is Intel-only (arch_i64), then output each app's path.
		intel_app_list=$(echo "$intel_app_list" | jq -r '.SPApplicationsDataType[] | select(.arch_kind=="arch_i64") | .path')

		# Filter to only get applications in /Applications, /Library and /usr/local
		intel_app_list=$(echo "$intel_app_list" | /usr/bin/grep -E "^[^/]*/(Applications|Library|usr/local)/")

		if [[ -n "$intel_app_list" ]]; then
			echo "$intel_app_list" > "$intel_app_logfile"
			echo "List of detected Intel-based applications available in $intel_app_logfile"
		else
		    echo "No Intel-based applications found in /Applications, /Library or /usr/local." > "$intel_app_logfile"
		fi
	fi
else
echo "ERROR: You must be root in order to run this script!"
ERROR=1
fi

exit $ERROR