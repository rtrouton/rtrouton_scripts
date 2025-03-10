#!/bin/bash

# This Jamf Pro Extension Attribute is designed to list the contents
# of the /Library/Logs/DiagnosticReports directory and check the most
# recently created log file with the file suffix of ".panic" for the 
# process which caused the most recent kernel panic.

lastPanicCause=""

# Get the latest panic log from the /Library/Logs/DiagnosticReports directory.

latestPanicLog=$(/usr/bin/find /Library/Logs/DiagnosticReports  -not -path '*/\.*' -name "*.panic" -type f 2>/dev/null | xargs /bin/ls -t1 | /usr/bin/head -1)

if [[ -n "$latestPanicLog" && -r "$latestPanicLog" ]]; then

	# Check the latest panic log for the process which caused the
	# most recent panic. This check process is slightly different between
	# Apple Silicon Macs and Intel Macs, so the Mac's processor is checked
	# to see if it's an Apple Silicon Mac or not and then run the appropriate
	# check on the latest panic log.
	
	if [[ "$(/usr/bin/uname -m)" =~ ^arm ]]; then
		lastPanicCause=$(/usr/bin/sed -n 's/.*Panicked task \([^\\]*\).*/\1/p' "$latestPanicLog" | /usr/bin/awk '{print $NF}')
	else
		lastPanicCause=$(/usr/bin/sed -n 's/.*corresponding to current thread: \([^\\]*\).*/\1/p' "$latestPanicLog")
	fi
fi

echo "<result>$lastPanicCause</result>"

exit 0
